var assuming = require("mocha-assume").assuming;

var TagDB = artifacts.require("TagDB");

var testCases = [
  {
    name: "tag-no-index",
    tag: "a",
    box: "1",
    state: "tag",
    index: "none",
    expectations: {
      boxHasTag: true,
      tagHasBox: false,
      tagExists: false
    }
  },
  {
    name: "tag-index-before",
    tag: "a",
    box: "1",
    state: "tag",
    index: "before",
    expectations: {
      boxHasTag: true,
      tagHasBox: true,
      tagExists: true
    }
  },
  {
    name: "tag-index-after",
    tag: "a",
    box: "1",
    state: "tag",
    index: "after",
    expectations: {
      boxHasTag: true,
      tagHasBox: true,
      tagExists: true
    }
  },
];

function runTest(db, test) {
  var setup = test.setup || [];

  var state = test.state || "tag";
  var index = test.index || "none";

  var boxID = web3.toAscii(web3.sha3(test.box));

  return Promise.resolve().then(function() {
    if (index == "before") {
      return db.indexBox(boxID);
    } else {
      return Promise.resolve()
    }
  }).then(function() {
    return db.tagBox(boxID, test.tag);
  }).then(function() {
    if (index == "after") {
      return db.indexBox(boxID);
    }
  });
}

contract("TagDB", function(accounts) {
  /* create separate context for each test case */
  testCases.forEach(function(test) {
    describe(test.name, function() {

      var db;
      beforeEach("Deploy new TagDB", function() {
        return TagDB.new().then(function(_db) { db = _db; });
      });

      beforeEach("Run test case", function() {
        return runTest(db, test);
      });

      assuming(
        test.expectations.tagExists !== undefined
      ).it("should correctly include or exclude tag via tagExists()", function() {
        return db.tagExists(test.tag).then(function(exists) {
          assert.equal(exists, test.expectations.tagExists);
        });
      });

      /* post-check for tags list inclusion for CSV string */
      assuming(
        test.expectations.tagExists !== undefined
      ).it("should correctly include or exclude tag from tagsComma()", function() {
        return db.tagsComma().then(function(csvTags) {
          var tags = csvTags.split(",");

          assert(
            test.expectations.tagExists == tags.includes(test.tag),

            "Afterwards, tags response string should" +
              (test.expectations.tagExists ? " " : " NOT ") +
              "contain tag `" + test.tag + "` " +
              "(got: \"" +  csvTags + "\")."
          );
        });
      });
    });
  });
});
