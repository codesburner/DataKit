/*jslint node: true, es5: true, nomen: true, regexp: true, indent: 2*/
/*global emit*/
"use strict";

var express = require('express');
var assert = require('assert');
var mongo = require('mongodb');
var crypto = require('crypto');
var fs = require('fs');
var doSync = require('sync');
var uuid = require('node-uuid');
var mkdirp = require('mkdirp');
var app = {};

// private functions
var _conf = {};
var _db = {};
var _def = function (v) {
  return (typeof v !== 'undefined');
};
var _exists = function (v) {
  return _def(v) && v !== null;
};
var _safe = function (v, d) {
  return _def(v) ? v : d;
};
var _secureMethod = function (m) {
  return function (req, res) {
    var s = req.header('x-datakit-secret', null);
    if (_exists(s) && s === _conf.secret) {
      return m(req, res);
    }
    res.header('WWW-Authenticate', 'datakit-secret');
    res.send(401);
  };
};
var _mkdirs = function (dirs, mode, cb) {
  var f = function next(e) {
    if (!e && dirs.length) {
      fs.mkdir(dirs.shift(), mode, next);
    } else {
      cb(e);
    }
  };
  f(null);
};
var _createRoutes = function (path) {
  var m = function (p) {
    return path + '/' + _safe(p, '');
  };
  app.get(m(), exports.info);
  app.get(m('public/:key'), exports.getPublishedObject);
  app.post(m('publish'), _secureMethod(exports.publishObject));
  app.post(m('save'), _secureMethod(exports.saveObject));
  app.post(m('delete'), _secureMethod(exports.deleteObject));
  app.post(m('refresh'), _secureMethod(exports.refreshObject));
  app.post(m('query'), _secureMethod(exports.query));
  app.post(m('index'), _secureMethod(exports.index));
  app.post(m('destroy'), _secureMethod(exports.destroy));
  app.post(m('store'), _secureMethod(exports.store));
  app.post(m('unlink'), _secureMethod(exports.unlink));
  app.get(m('stream'), _secureMethod(exports.stream));
  app.post(m('exists'), _secureMethod(exports.exists));
};
var _parseMongoException = function (e) {
  if (!_exists(e)) {
    return null;
  }
  var lastErr = e.lastErrorObject;
  if (_exists(lastErr)) {
    return {'status': lastErr.code, 'message': lastErr.err};
  }
  return null;
};
var _e = function (res, snm, err) {
  var eo, me, stackLines, l;
  eo = {'status': snm[0], 'message': snm[1]};
  me = _parseMongoException(err);
  if (me !== null) {
    eo.err = me.message;
  } else if (_exists(err)) {
    eo.err = String(err.message);
    stackLines = err.stack.split(/\n/g);
    stackLines[1].replace(/at\s+\S*?([^\/]+):(\d+):(\d+)/g, function (a, f, l, c) {
      l = [f, l, c].join(":");
      console.error("error returned at", l);
    });
  }
  return res.json(eo, 400);
};
var _c = {
  red: '\u001b[31m',
  green: '\u001b[32m',
  yellow: '\u001b[33m',
  blue: '\u001b[34m',
  purple: '\u001b[34m',
  reset: '\u001b[0m'
};
var _ERR = {
  ENTITY_NOT_SET: [100, 'Entity not set'],
  ENTITY_KEY_NOT_SET: [101, 'Entity key not set'],
  OBJECT_ID_NOT_SET: [102, 'Object ID not set'],
  OBJECT_ID_INVALID: [103, 'Object ID invalid'],
  SAVE_FAILED: [200, 'Save failed'],
  SAVE_FAILED_DUPLICATE_KEY: [201, 'Save failed because of a duplicate key'],
  DELETE_FAILED: [300, 'Delete failed'],
  REFRESH_FAILED: [400, 'Refresh failed'],
  QUERY_FAILED: [500, 'Query failed'],
  INDEX_FAILED: [600, 'Index failed'],
  PUBLISH_FAILED: [700, 'Publish failed'],
  DESTROY_FAILED: [800, 'Destroy failed'],
  DESTROY_NOT_ALLOWED: [801, 'Destroy not allowed'],
  STORE_FAILED: [900, 'File store failed'],
  STORE_FILE_EXISTS: [901, 'File already exists'],
  STORE_COULD_NOT_OPEN: [902, 'Could not open the file store'],
  STORE_COULD_NOT_APPEND: [903, 'Could not append to file'],
  UNLINK_FAILED: [1000, 'Unlink failed'],
  FILE_EXISTS: [1100, 'File exists'],
  FILE_EXISTS_FAILED: [1101, 'File exists failed']
};
var _copyKeys = function (s, t) {
  var key;
  for (key in s) {
    if (s.hasOwnProperty(key)) {
      t[key] = s[key];
    }
  }
};
var _traverse = function (o, func) {
  var i;
  for (i in o) {
    if (o.hasOwnProperty(i)) {
      func.apply(o, [i, o[i]]);
      if (typeof (o[i]) === 'object') {
        _traverse(o[i], func);
      }
    }
  }
};
var _decodeDkObj = function (o) {
  _traverse(o, function (key, value) {
    if (key === 'dk:data') {
      this[key] = new Buffer(value, 'base64');
    }
    if (key === '$id') {
      this[key] = new mongo.ObjectID(value);
    }
  });
};
var _encodeDkObj = function (o) {
  _traverse(o, function (key, value) {
    if (key === 'dk:data') {
      this[key] = value.toString('base64');
    }
  });
};
var _generateNextSequenceNumber = function (entity) {
  var col, doc;
  col = _db.collection.sync(_db, 'DataKit:Sequence');
  col.insert.sync(col, {'_id': entity, 'seq': new mongo.Long(0)});
  doc = col.findAndModify.sync(
    col,
    {'_id': entity},
    [],
    {'$inc': {'seq': 1}},
    {'new': true}
  );

  return doc.seq;
};
// prototypes
String.prototype.repeat = function (num) {
  var a = [];
  a.length = parseInt(num, 10) + 1;
  return a.join(this);
};
// exported functions
exports.run = function (c) {
  doSync(function runSync() {
    var pad, nl, buf, srv, db, parse;
    pad = '-'.repeat(80);
    nl = '\n';
    console.log(nl + pad + nl + 'DATAKIT' + nl + pad);
    _conf.db = _safe(c.db, 'datakit');
    _conf.dbhost = _safe(c.dbhost, 'localhost');
    _conf.dbport = _safe(c.dbport, mongo.Connection.DEFAULT_PORT);
    _conf.path = _safe(c.path, '');
    _conf.port = _safe(c.port, process.env.PORT || 3000);
    _conf.secret = _safe(c.secret, null);
    _conf.salt = _safe(c.salt, "datakit");
    _conf.allowDestroy = _safe(c.allowDestroy, false);
    _conf.cert = _safe(c.cert, null);
    _conf.key = _safe(c.key, null);
    _conf.express = _safe(c.express, function (app) {});
    _conf.tempDir = _safe(c.tempDir, __dirname + "/tmp");

    if (_exists(_conf.cert) && _exists(_conf.key)) {
      app = express.createServer({
        'key': fs.readFileSync(_conf.key),
        'cert': fs.readFileSync(_conf.cert)
      });
    } else {
      app = express.createServer();
    }

    // Install the body parser
    parse = express.bodyParser();
    app.use(parse);

    if (_conf.secret === null) {
      buf = crypto.randomBytes.sync(crypto, 32);
      _conf.secret = buf.toString('hex');
      console.log(_c.red + 'WARN:\tNo secret found in config, generated new one.\n',
                  '\tCopy this secret to your DataKit iOS app and server config!\n\n',
                  _c.yellow,
                  '\t' + _conf.secret, nl, nl,
                  _c.red,
                  '\tTerminating process.',
                  _c.reset);
      process.exit(1);
    }
    if (_conf.secret.length !== 64) {
      console.log(_c.red, '\nSecret is not a hex string of length 64 (256 bytes), terminating process.\n', _c.reset);
      process.exit(2);
    }

    console.log('CONF:', JSON.stringify(_conf, undefined, 2), nl);

    // Create API routes
    _createRoutes(_conf.path);
    _conf.express(app);

    // Connect to DB and run
    srv = new mongo.Server(_conf.dbhost, _conf.dbport, {});
    db = new mongo.Db(_conf.db, srv);
    try {
      _db = db.open.sync(db);
      app.listen(_conf.port, function appListen() {
        console.log(_c.green + 'DataKit started on port', _conf.port, _c.reset);
      });
    } catch (e) {
      console.error(e);
    }
  });
};
exports.info = function (req, res) {
  res.send('datakit', 200);
};
exports.getPublishedObject = function (req, res) {
  doSync(function publicSync() {
    var key, col, result, oid, fields;
    key = req.param('key', null);
    if (!_exists(key)) {
      return res.send(404);
    }

    try {
      col = _db.collection.sync(_db, 'DataKit:Public');
      result = col.findOne.sync(col, {'_id': key});

      oid = new mongo.ObjectID(result.q.oid);
      fields = result.q.fields;

      col = _db.collection.sync(_db, result.q.entity);
      result = col.findOne.sync(col, {'_id': oid}, fields);

      if (fields.length === 1) {
        return res.send(result[fields[0]], 200);
      } else {
        return res.json(result, 200);
      }
    } catch (e) {
      console.error(e);
    }

    return res.send(404);
  });
};
exports.publishObject = function (req, res) {
  doSync(function publishSync() {
    var entity, oid, fields, query, signature, shasum, key, col; //, cipher, enc, base64, urlSafeBase64;
    entity = req.param('entity', null);
    if (!_exists(entity)) {
      return _e(res, _ERR.ENTITY_NOT_SET);
    }
    oid = req.param('oid', null);
    if (!_exists(oid)) {
      return _e(res, _ERR.OBJECT_ID_INVALID);
    }
    fields = req.param('fields', null);
    query = {
      'entity': entity,
      'oid': oid,
      'fields': []
    };
    if (fields !== null && fields.length > 0) {
      query.fields = fields;
    }

    signature = _conf.secret + _conf.salt + query;
    shasum = crypto.createHash('sha512');
    shasum.update(signature);
    key = shasum.digest('base64');
    key.replace(/\+/g, '-');
    key.replace(/\//g, '_');

    try {
      col = _db.collection.sync(_db, 'DataKit:Public');
      col.update.sync(col, {'_id': key}, {'$set': {'q': query}}, {'safe': true, 'upsert': true});

      return res.json(key, 200);
    } catch (e) {
      console.error(e);
      return _e(res, _ERR.PUBLISH_FAILED, e);
    }
  });
};
exports.saveObject = function (req, res) {
  doSync(function saveSync() {
    var i, entities, results, errors, ent, entity, oidStr, fset, funset, finc, fpush, fpushAll, faddToSet, fpop, fpullAll, oid, ts, collection, doc, isNew, opts, update, ats, key;
    entities = req.body;
    results = [];
    errors = [];

    for (i in entities) {
      if (entities.hasOwnProperty(i)) {
        ent = entities[i];
        entity = _safe(ent.entity, null);
        if (!_exists(entity)) {
          return _e(res, _ERR.ENTITY_NOT_SET);
        }
        oidStr = _safe(ent.oid, null);
        fset = _safe(ent.set, {});
        funset = _safe(ent.unset, null);
        finc = _safe(ent.inc, null);
        fpush = _safe(ent.push, null);
        fpushAll = _safe(ent.pushAll, null);
        faddToSet = _safe(ent.addToSet, null);
        fpop = _safe(ent.pop, null);
        fpullAll = _safe(ent.pullAll, null);
        oid = null;

        _decodeDkObj(fset);
        _decodeDkObj(fpush);
        _decodeDkObj(fpushAll);
        _decodeDkObj(faddToSet);
        _decodeDkObj(fpullAll);

        if (_exists(oidStr)) {
          oid = new mongo.ObjectID(oidStr);
          if (!_exists(oid)) {
            return _e(res, _ERR.OBJECT_ID_INVALID);
          }
        }
        try {
          ts = parseInt((new Date().getTime()) / 1000, 10);
          collection = _db.collection.sync(_db, entity);
          isNew = (oid === null);

          // Automatically insert the update timestamp
          fset._updated = ts;

          // Insert new object
          if (isNew) {
            // Generate new sequence number         
            fset._seq = _generateNextSequenceNumber(entity);
            doc = collection.insert.sync(collection, fset);
            oid = doc[0]._id;
          }

          // Update instead if oid exists, or an operation needs to be executed
          // that requires an insert first.
          opts = {'upsert': true, 'new': true};
          update = {};
          if (_exists(fset) && !isNew) {
            update.$set = fset;
          }
          if (_exists(funset)) {
            update.$unset = funset;
          }
          if (_exists(finc)) {
            update.$inc = finc;
          }
          if (_exists(fpush)) {
            update.$push = fpush;
          }
          if (_exists(fpushAll)) {
            update.$pushAll = fpushAll;
          }
          if (_exists(faddToSet)) {
            ats = {};
            for (key in faddToSet) {
              if (faddToSet.hasOwnProperty(key)) {
                ats[key] = {'$each': faddToSet[key]};
              }
            }
            update.$addToSet = ats;
          }
          if (_exists(fpop)) {
            update.$pop = fpop;
          }
          if (_exists(fpullAll)) {
            update.$pullAll = fpullAll;
          }

          // Find and modify
          if (!isNew || (isNew && Object.keys(update).length > 0)) {
            doc = collection.findAndModify.sync(collection, {'_id': oid}, [], update, opts);
          }

          if (doc.length > 0) {
            doc = doc[0];
          }

          _encodeDkObj(doc);

          results.push(doc);
        } catch (e) {
          console.error(e);
          errors.push(e);
        }
      }
    }
    if (errors.length > 0) {
      return _e(res, _ERR.SAVE_FAILED, errors.pop());
    }
    res.json(results, 200);
  });
};
exports.deleteObject = function (req, res) {
  doSync(function deleteSync() {
    var entity, oidStr, oid, collection, result;
    entity = req.param('entity', null);
    oidStr = req.param('oid', null);
    if (!_exists(entity)) {
      return _e(res, _ERR.ENTITY_NOT_SET);
    }
    if (!_exists(oidStr)) {
      return _e(res, _ERR.OBJECT_ID_NOT_SET);
    }
    oid = new mongo.ObjectID(oidStr);
    if (!_exists(oid)) {
      return _e(res, _ERR.OBJECT_ID_INVALID);
    }
    try {
      collection = _db.collection.sync(_db, entity);
      result = collection.remove.sync(collection, {'_id': oid}, {'safe': true});
      res.send('', 200);
    } catch (e) {
      console.error(e);
      return _e(res, _ERR.DELETE_FAILED, e);
    }
  });
};
exports.refreshObject = function (req, res) {
  doSync(function refreshSync() {
    var entity, oidStr, oid, collection, result;
    entity = req.param('entity', null);
    oidStr = req.param('oid', null);
    if (!_exists(entity)) {
      return _e(res, _ERR.ENTITY_NOT_SET);
    }
    if (!_exists(oidStr)) {
      return _e(res, _ERR.OBJECT_ID_NOT_SET);
    }
    oid = new mongo.ObjectID(oidStr);
    if (!_exists(oid)) {
      return _e(res, _ERR.OBJECT_ID_INVALID);
    }
    try {
      collection = _db.collection.sync(_db, entity);
      result = collection.findOne.sync(collection, {'_id': oid});
      if (!_exists(result)) {
        throw 'Could not find object';
      }

      _encodeDkObj(result);

      res.json(result, 200);
    } catch (e) {
      console.error(e);
      return _e(res, _ERR.REFRESH_FAILED, e);
    }
  });
};
exports.query = function (req, res) {
  doSync(function querySync() {
    var entity, doFindOne, doCount, query, opts, or, and, incl, sort, skip, limit, mr, mrOpts, sortValues, order, results, cursor, collection, result, key, resultCount, i, j, field, dbRef, resolved;
    entity = req.param('entity', null);
    if (!_exists(entity)) {
      return _e(res, _ERR.ENTITY_NOT_SET);
    }
    doFindOne = req.param('findOne', false);
    doCount = req.param('count', false);
    query = req.param('q', {});
    opts = {};
    or = req.param('or', null);
    and = req.param('and', null);
    incl = req.param('incl', []);
    sort = req.param('sort', null);
    skip = req.param('skip', null);
    limit = req.param('limit', null);
    mr = req.param('mr', null);

    if (_exists(or)) {
      query.$or = or;
    }
    if (_exists(and)) {
      query.$and = and;
    }
    if (_exists(sort)) {
      sortValues = [];
      for (key in sort) {
        if (sort.hasOwnProperty(key)) {
          order = (sort[key] === 1) ? 'asc' : 'desc';
          sortValues.push([key, order]);
        }
      }
      opts.sort = sortValues;
    }
    if (_exists(skip)) {
      opts.skip = parseInt(skip, 10);
    }
    if (_exists(limit)) {
      opts.limit = parseInt(limit, 10);
    }

    // replace oid strings with oid objects
    _traverse(query, function (key, value) {
      if (key === '_id') {
        this[key] = new mongo.ObjectID(value);
      }
    });

    try {
      // TODO: remove debug query log
      console.log('query', entity, '=>', JSON.stringify(query), JSON.stringify(opts));

      collection = _db.collection.sync(_db, entity);

      if (mr !== null) {
        mrOpts = {
          'query': query,
          'out': {'inline': 1}
        };
        if (_exists(opts.sort)) {
          mrOpts.sort = opts.sort;
        }
        if (_exists(opts.limit)) {
          mrOpts.limit = opts.limit;
        }
        if (_exists(mr.context)) {
          mrOpts.scope = mr.context;
        }
        if (_exists(mr.finalize)) {
          mrOpts.finalize = mr.finalize;
        }
        results = collection.mapReduce.sync(
          collection,
          mr.map,
          mr.reduce,
          mrOpts
        );
      } else {
        if (doFindOne) {
          opts.limit = 1;
        }
        cursor = collection.find.sync(collection, query, opts);

        if (doCount) {
          results = cursor.count.sync(cursor);
        } else {
          results = cursor.toArray.sync(cursor);
          resultCount = Object.keys(results).length;

          if (resultCount > 1000) {
            console.log(_c.yellow + 'warning: query',
                        entity,
                        '->',
                        query,
                        'returned',
                        resultCount,
                        'results, may impact server performance negatively. try to optimize the query!',
                        _c.reset);
          }

          for (i in results) {
            if (results.hasOwnProperty(i)) {
              for (j in incl) {
                if (incl.hasOwnProperty(j)) {
                  result = results[i];
                  field = incl[j];
                  dbRef = result[field];
                  try {
                    resolved = _db.dereference.sync(_db, dbRef);
                    if (_def(resolved)) {
                      result[field] = resolved;
                    }
                  } catch (refErr) {
                    console.error('error: could not resolve reference for key "' + field + '"');
                    console.error(refErr);
                  }
                }
              }
            }
          }
        }
      }

      _encodeDkObj(results);

      return res.json(results, 200);
    } catch (e) {
      console.error(e);
      return _e(res, _ERR.QUERY_FAILED, e);
    }
  });
};
exports.index = function (req, res) {
  doSync(function indexSync() {
    var entity, key, unique, drop, opts, collection, cursor;
    entity = req.param('entity', null);
    key = req.param('key', null);
    unique = req.param('unique', false);
    drop = req.param('drop', false);
    if (!_exists(entity)) {
      return _e(res, _ERR.ENTITY_NOT_SET);
    }
    if (!_exists(key)) {
      return _e(res, _ERR.ENTITY_KEY_NOT_SET);
    }
    try {
      opts = {
        'safe': true,
        'unique': unique,
        'dropDups': drop
      };
      collection = _db.collection.sync(_db, entity);
      cursor = collection.ensureIndex.sync(collection, {key: 1}, opts);

      return res.send('', 200);
    } catch (e) {
      return _e(res, _ERR.INDEX_FAILED, e);
    }
  });
};
exports.destroy = function (req, res) {
  doSync(function destroySync() {
    if (!_conf.allowDestroy) {
      return _e(res, _ERR.DESTROY_NOT_ALLOWED);
    }
    var entity, collection;
    entity = req.param('entity', null);
    if (!_exists(entity)) {
      return _e(res, _ERR.ENTITY_NOT_SET);
    }
    try {
      collection = _db.collection.sync(_db, entity);
      collection.drop.sync(collection);

      return res.send('', 200);
    } catch (e) {
      return _e(res, _ERR.DESTROY_FAILED, e);
    }
  });
};
exports.store = function (req, res) {
  doSync(function storeSync() {
    // Get filename and mode
    var fileName, store, bufs, onEnd, onClose, onCancel, isClosing, pendingWrites, tick, gs;
    fileName = req.header('x-datakit-filename', null);

    // Generate filename if neccessary, else check for conflict
    if (fileName === null) {
      fileName = uuid.v4();
    }

    store = null;
    bufs = [];
    onEnd = false;
    onClose = false;
    onCancel = false;
    isClosing = false;
    pendingWrites = 0;
    tick = function (data) {
      if (data && !(onClose || onCancel)) {
        bufs.push(data);
      }
      if (pendingWrites <= 0 && bufs.length === 0 && (onClose || onEnd || onCancel)) {
        if (!isClosing) {
          isClosing = true;
          store.close(function () {
            if (onClose) {
              console.log("connection closed, unlink file");
              // Remove the file if stream was closed prematurely
              mongo.GridStore.unlink(_db, fileName, function (err) {
                res.send('', 400);
              });
            } else if (onEnd) {
              res.send('', 200);
            }
            store = null;
          });
        }
      }
      if (store !== null && bufs.length > 0 && pendingWrites <= 0) {
        pendingWrites += 1;
        store.write(bufs.shift(), function (err, success) {
          if (err) {
            console.error('error: could not write chunk (', err, ')');
          }
          pendingWrites -= 1;
          tick();
        });
      }
    };

    // Register handlers
    req.on('end', function () {
      onEnd = true;
      tick(null);
    });
    req.on('close', function () {
      onClose = true;
      tick(null);
    });
    req.on('data', function (data) {
      tick(data);
    });

    // Pipe to GridFS
    gs = new mongo.GridStore(_db, fileName, 'w+', {
      // Generally the chunk size doesn't matter much,
      // we just use a smaller chunk size to verify file
      // integrity when testing.
      'chunkSize': 1024 * 50
    });
    gs.open(function (err, s) {
      if (err) {
        console.log(err);
        bufs = [];
        onCancel = true;
        return _e(res, _ERR.STORE_COULD_NOT_OPEN, err);
      }
      store = s;
      tick();
    });
  });
};
exports.unlink = function (req, res) {
  doSync(function unlinkSync() {
    var files, i, gs, lastErr;
    files = req.param('files', []);
    gs = mongo.GridStore;
    lastErr = null;
    for (i = 0; i < files.length; i += 1) {
      try {
        gs.unlink.sync(gs, _db, files[i]);
      } catch (e) {
        lastErr = e;
      }
    }
    if (lastErr !== null) {
      return _e(res, _ERR.UNLINK_FAILED, lastErr);
    }
    return res.send('', 200);
  });
};
exports.stream = function (req, res) {
  doSync(function streamSync() {
    var k, gs, stream;
    k = req.header('x-datakit-filename', null);
    if (!k) {
      // HTTP: Not Found
      return res.send('', 404);
    }

    // Open grid store
    gs = new mongo.GridStore(_db, k, 'r');
    try {
      gs = gs.open.sync(gs);
    } catch (e) {
      console.log(e);
      // HTTP: Server Error
      return res.send('', 500);
    }

    // Write head
    // HTTP: Partial Content
    console.log(k, "=>", "content", gs.contentType, "len", gs.length);
    res.writeHead(200, {
      'Connection': 'close',
      'Content-Type': gs.contentType,
      'Content-Length': gs.length
    });

    stream = gs.stream(true);
    stream.on('data', function (data) {
      res.write(data);
    });
    stream.on('close', function () {
      res.end();
    });
  });
};
exports.exists = function (req, res) {
  doSync(function existsSync() {
    var fileName, gs, exists;
    fileName = req.param('fileName', null);
    if (fileName) {
      gs = mongo.GridStore;
      try {
        exists = gs.exist.sync(gs, _db, fileName);
        if (exists) {
          return res.send('', 200);
        }
      } catch (e) {
        console.error(e);
        return _e(res, _ERR.EXISTS_FAILED, e);
      }
    }
    return _e(res, _ERR.FILE_EXISTS);
  });
};



