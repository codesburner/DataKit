var express = require("express"),
    assert = require("assert"),
    mongo = require("mongodb"),
    crypto = require("crypto"),
    fs = require("fs"),
    doSync = require("sync"),
    app = {};

// private functions
var _conf = {};
var _db = {};
var _createRoutes = function(path) {
  var m = function(p) {
    return path + "/" + _safe(p, "");
  };
  app.get(m(), exports.info);
  app.get(m("public/:obj"), exports.public);
  app.post(m("publish"), _secureMethod(exports.publishObject));
  app.post(m("save"), _secureMethod(exports.saveObject));
  app.post(m("delete"), _secureMethod(exports.deleteObject));
  app.post(m("refresh"), _secureMethod(exports.refreshObject));
  app.post(m("query"), _secureMethod(exports.query));
}
var _e = function(res, snm, err) {
  var eo = {"status": snm[0], "message": snm[1]};
  if (_exists(err)) {
    eo.err = String(err);
  }
  return res.json(eo, 400);
}
var _c = {
  red: "\u001b[31m",
  green: "\u001b[32m",
  yellow: "\u001b[33m",
  blue: "\u001b[34m",
  purple: "\u001b[34m",
  reset: "\u001b[0m"
}
var _ERR = {
  ENTITY_NOT_SET: [100, "Entity not set"],
  OBJECT_ID_NOT_SET: [101, "Object ID not set"],
  OBJECT_ID_INVALID: [102, "Object ID invalid"],
  SAVE_FAILED: [200, "Save failed"],
  DELETE_FAILED: [300, "Delete failed"],
  REFRESH_FAILED: [400, "Refresh failed"],
  QUERY_FAILED: [500, "Query failed"]
}
var _def = function(v) {
  return (typeof v !== "undefined");
}
var _exists = function(v) {
  return _def(v) && v !== null;
}
var _safe = function(v, d) {
  return _def(v) ? v : d;
}
var _secureMethod = function(m) {
  return (function(req, res) {
    var s = req.header("x-datakit-secret", null);
    if (_exists(s) && s === _conf.secret) {
      return m(req, res);
    }
    res.header("WWW-Authenticate", "datakit-secret");
    res.send(401);
  });
}
var _copyKeys = function(s, t) {
  for (key in s) t[key] = s[key];
}
var _traverse = function(o, func) {
  for (i in o) {
    func.apply(o, [i, o[i]]);
    if (typeof(o[i]) == "object") {
      _traverse(o[i], func);
    }
  }
}
var _decodeDkObj = function(o) {
  _traverse(o, function(key, value) {
    if (key === "dkdata!") {
      this[key] = new Buffer(value, "base64");
    }
  });
}
var _encodeDkObj = function(o) {
  _traverse(o, function(key, value) {
    if (key === "dkdata!") {
      this[key] = value.toString("base64");
    }
  });
}

// exported functions
exports.run = function(c) {
  doSync(function() {
    var pad = "--------------------------------------------------------------------------------";
    var nl = "\n";
    console.log(nl + pad + nl + "DATAKIT" + nl + pad);
    _conf.db = _safe(c.db, "datakit");
    _conf.dbhost = _safe(c.dbhost, "localhost");
    _conf.dbport = _safe(c.dbport, mongo.Connection.DEFAULT_PORT);
    _conf.path = _safe(c.path, "");
    _conf.port = _safe(c.port, process.env.PORT || 3000);
    _conf.secret = _safe(c.secret, null);
    _conf.cert = _safe(c.cert, null);
    _conf.key = _safe(c.key, null);
    
    if (_exists(_conf.cert) && _exists(_conf.key)) {
      app = express.createServer({
        "key": fs.readFileSync(_conf.key),
        "cert": fs.readFileSync(_conf.cert)
      });
    }
    else {
      app = express.createServer()
    }
    app.use(express.bodyParser());
    
    if (_conf.secret == null) {
      var buf = crypto.randomBytes.sync(crypto, 32);
      _conf.secret = buf.toString("hex");
      console.log(_c.red + "WARN:\tNo secret found in config, generated new one.\n",
                  "\tCopy this secret to your DataKit iOS app and server config!\n\n",
                  _c.yellow,
                  "\t" + _conf.secret, nl, nl,
                  _c.red,
                  "\tTerminating process.",
                  _c.reset);
      process.exit(code=1);
    }
    if (_conf.secret.length !== 64) {
      console.log(_c.red, "\nSecret is not a hex string of length 64 (256 bytes), terminating process.\n", _c.reset);
      process.exit(code=2);
    }

    console.log("CONF:", JSON.stringify(_conf, undefined, 2), nl);

    // Create API routes
    _createRoutes(_conf.path);

    // Connect to DB and run
    var srv = new mongo.Server(_conf.dbhost, _conf.dbport, {});
    var db = new mongo.Db(_conf.db, srv);
    try {
      _db = db.open.sync(db);
      app.listen(_conf.port, function() {
        console.log(_c.green + "DataKit started on port", _conf.port, _c.reset);
      });
    }
    catch (e) {
      console.error(e);
    }
  });
}
exports.info = function(req, res) {
  res.send("datakit", 200);
}
exports.public = function(req, res) {
  doSync(function() {
    var obj = req.param("obj", null);
    if (_exists(obj)) {
      obj = obj.replace(/-/g, "+").replace(/_/g, "/");
      var objBuf = new Buffer(obj, "base64");
      var decipher = crypto.createDecipher("aes-256-cbc", _conf.secret);
      var dec = decipher.update(objBuf, "binary", "utf8");
      dec += decipher.final("utf8");
      
      if (_exists(dec) && dec.length > 0) {
        var c = dec.split(":");
        if (c.length > 1) {
          var entity = c[0];
          var oid = null;
          try {
            oid = new mongo.ObjectID(c[1]);
          }
          catch (e) {
            // ignore invalid oid errors, check for null oid in next stepx
          };
          if (oid !== null && entity.length > 0) {
            var fields = [];
            if (c.length > 2) {
              fields = c.splice(2, c.length-1);
            }
            try {
              var collection = _db.collection.sync(_db, entity);
              var result = collection.findOne.sync(collection, {"_id": oid}, fields);
              if (_exists(result)) {
                delete result["_id"];
                // if only one field was requested we return the data of that field
                // directly instead of the JSON representation
                if (fields.length == 1) {
                  res.send(result[fields[0]], 200);
                }
                else {
                  res.json(result, 200);
                }
                return;
              }
            }
            catch (e) {
              console.error(e)
            }
          }
        }
      }
    }
    res.send(404);
  })
}
exports.publishObject = function(req, res) {
  doSync(function() {
    var entity = req.param("entity", null);
    if (!_exists(entity)) {
      return _e(res, _ERR.ENTITY_NOT_SET);
    }
    var oid = req.param("oid", null);
    if (!_exists(oid)) {
      return _e(res, _ERR.OBJECT_ID_INVALID);
    }
    var fields = req.param("fields", null);
    var str = entity + ":" + oid;
    if (fields !== null && fields.length > 0) {
      str += ":" + fields.join(":");
    }
    var cipher = crypto.createCipher("aes-256-cbc", _conf.secret);
    var enc = cipher.update(str, "utf8", "hex");
    enc += cipher.final("hex");
    var base64 = new Buffer(enc, "hex").toString("base64");
    var urlSafeBase64 = base64.replace(/\+/g, "-").replace(/\//g, "_");
    
    res.json(urlSafeBase64, 200);
  })
}
exports.saveObject = function(req, res) {
  doSync(function() {
    var entity = req.param("entity", null);
    if (!_exists(entity)) {
      return _e(res, _ERR.ENTITY_NOT_SET);
    }
    var oidStr = req.param("oid", null);
    var fset = req.param("set", {});
    var funset = req.param("unset", null);
    var finc = req.param("inc", null);
    var fpush = req.param("push", null);
    var fpushAll = req.param("pushAll", null);
    var faddToSet = req.param("addToSet", null);
    var fpop = req.param("pop", null);
    var fpullAll = req.param("pullAll", null);
    var oid = null;
    
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
      var ts = parseInt((new Date().getTime()) / 1000);
      var collection = _db.collection.sync(_db, entity);
      var doc;
      if (oid !== null) {
        var opts = {"upsert": true, "new": true};
        var update = {};
        if (_exists(fset)) update["$set"] = fset;
        if (_exists(funset)) update["$unset"] = funset;
        if (_exists(finc)) update["$inc"] = finc;
        if (_exists(fpush)) update["$push"] = fpush;
        if (_exists(fpushAll)) update["$pushAll"] = fpushAll;
        if (_exists(faddToSet)) {
          var ats = {}
          for (var key in faddToSet) {
             ats[key] = {"$each": faddToSet[key]};
          }
          update["$addToSet"] = ats;
        }
        if (_exists(fpop)) update["$pop"] = fpop;
        if (_exists(fpullAll)) update["$pullAll"] = fpullAll;
        fset["_updated"] = ts;
        doc = collection.findAndModify.sync(collection, {"_id": oid}, [], update, opts);
      }
      else {
        fset["_updated"] = ts;
        doc = collection.insert.sync(collection, fset);
      }
      if (doc.length > 0) {
        doc = doc[0];
      }
      
      _encodeDkObj(doc);
      
      res.json(doc, 200);
    }
    catch (e) {
      console.error(e);
      return _e(res, _ERR.SAVE_FAILED, e);
    }
  })
}
exports.deleteObject = function(req, res) {
  doSync(function() {
    var entity = req.param("entity", null);
    var oidStr = req.param("oid", null);
    if (!_exists(entity)) {
      return _e(res, _ERR.ENTITY_NOT_SET);
    }
    if (!_exists(oidStr)) {
      return _e(res, _ERR.OBJECT_ID_NOT_SET);
    }
    var oid = new mongo.ObjectID(oidStr);
    if (!_exists(oid)) {
      return _e(res, _ERR.OBJECT_ID_INVALID);
    }
    try {
      var collection = _db.collection.sync(_db, entity);
      var result = collection.remove.sync(collection, {"_id": oid}, {"safe": true});
      res.send('', 200);
    }
    catch (e) {
      console.error(e);
      return _e(res, _ERR.DELETE_FAILED, e);
    }
  })
}
exports.refreshObject = function(req, res) {
  doSync(function() {
    var entity = req.param("entity", null);
    var oidStr = req.param("oid", null);
    if (!_exists(entity)) {
      return _e(res, _ERR.ENTITY_NOT_SET);
    }
    if (!_exists(oidStr)) {
      return _e(res, _ERR.OBJECT_ID_NOT_SET);
    }
    var oid = new mongo.ObjectID(oidStr);
    if (!_exists(oid)) {
      return _e(res, _ERR.OBJECT_ID_INVALID);
    }
    try {
      var collection = _db.collection.sync(_db, entity);
      var result = collection.findOne.sync(collection, {"_id": oid});
      if (!_exists(result)) {
        throw "Could not find object";
      }
      
      _encodeDkObj(result);
      
      res.send(result, 200);
    }
    catch (e) {
      console.error(e);
      return _e(res, _ERR.REFRESH_FAILED, e);
    }
  })
}
exports.query = function(req, res) {
  doSync(function() {
    var entity = req.param("entity", null);
    if (!_exists(entity)) {
      return _e(res, _ERR.ENTITY_NOT_SET);
    }
    var query = req.param("q", {});
    var opts = {};
    var or = req.param("or", null);
    var and = req.param("and", null);
    var sort = req.param("sort", null);
    var skip = req.param("skip", null);
    var limit = req.param("limit", null);
    
    if (_exists(or)) query["$or"] = or;
    if (_exists(and)) query["$and"] = and;
    if (_exists(sort)) {
      var sortValues = [];
      for (key in sort) {
        var order = (sort[key] === 1) ? "asc" : "desc";
        sortValues.push([key, order]);
      }
      opts["sort"] = sortValues;
    }
    if (_exists(skip)) opts["skip"] = parseInt(skip);
    if (_exists(limit)) opts["limit"] = parseInt(limit);
    
    // replace oid strings with oid objects
    _traverse(query, function(key, value) {
      if (key == "_id") {
        this[key] = new mongo.ObjectID(value);
      }
    });
    
    try {
      // TODO: remove debug query log
      console.log("query", entity, "=>", JSON.stringify(query), JSON.stringify(opts));
      var collection = _db.collection.sync(_db, entity);
      var cursor = collection.find.sync(collection, query, opts);
      var results = cursor.toArray.sync(cursor);
      
      var resultCount = Object.keys(results).length;
      if (resultCount > 1000) {
        console.log(_c.yellow + "warning: query",
                    entity,
                    "->",
                    query,
                    "returned",
                    resultCount,
                    "results, may impact server performance negatively. try to optimize the query!",
                    _c.reset);
      }
      
      _encodeDkObj(results)
      
      res.send(results, 200);
    }
    catch (e) {
      console.error(e);
      return _e(res, _ERR.QUERY_FAILED, e);
    }
  })
}