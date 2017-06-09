var assuming = require("mocha-assume").assuming;

var TagDB = artifacts.require("TagDB");

var testCases = [
  {
    name: "tag-no-index",
    run: function(db) {
      return db.tagBox(boxID("1"), "a");
    },
    expected: {
      boxTags: {"1": ["a"]}
    },
    unexpected: {
      tags: ["a"],
    }
  },
  {
    name: "tag-index-before",
    run: function(db) {
      return Promise.resolve()
        .then(function() { return db.indexBox(boxID("1")); })
        .then(function() { return db.tagBox(boxID("1"), "a"); });
    },
    expected: {
      boxTags: {"1": ["a"]},
      tags: ["a"],
    }
  },
  {
    name: "tag-index-after",
    run: function(db) {
      return Promise.resolve()
        .then(function() { return db.tagBox(boxID("1"), "a"); })
        .then(function() { return db.indexBox(boxID("1")); });
    },
    expected: {
      boxTags: {"1": ["a"]},
      tags: ["a"],
    }
  },
  {
    name: "lots-of-tags-then-index",
    run: function(db) {
      tags = [
        "a","b","c","d","e","f","g","h","i","j","k","l","m","n", "o", "p",
        "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
      ];
      return Promise.all(tags.map(function(tag) {
        return db.tagBox(boxID("1"), tag);
      })).then(function() {
        return db.indexBox(boxID("1")).then(function(result) {
          var gasUsed = result.receipt.gasUsed;
          var gasLimit = web3.eth.getBlock(result.receipt.blockNumber).gasLimit;
          // console.log("index gas used: ", gasUsed);
          // console.log("index block gas limit: ", gasLimit);
          // console.log("difference: ", gasLimit - gasUsed);
        });
      });
    },
    expected: {
      boxTags: {"1": [
        "a","b","c","d","e","f","g","h","i","j","k","l","m","n", "o", "p",
        "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
      ]},
      tags: [
        "a","b","c","d","e","f","g","h","i","j","k","l","m","n", "o", "p",
        "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
      ],
    }
  },
];

function boxID(name) {
  return web3.toAscii(web3.sha3(name));
}

contract("TagDB", function(accounts) {
  /* create separate context for each test case */
  testCases.forEach(function(test) {
    describe(test.name, function() {

      /* set defaults */
      test.setup = test.setup || Promise.resolve;
      test.run = test.run || Promise.resolve;

      test.expected = test.expected || {};
      test.unexpected = test.unexpected || {};

      var db;
      beforeEach("Deploy new TagDB", function() {
        return TagDB.new().then(function(_db) { db = _db; });
      });

      beforeEach("Run test case", function() {
        return test.run(db);
      });

      assuming(
        test.expected.tags !== undefined || test.unexpected.tags !== undefined
      ).it("should meet tag existence expectations via tagExists()", function() {
        var expectations = (test.expected.tags || []).map(function(tag) {
          return db.tagExists(tag).then(function(exists) {
            assert.ok(exists, "expected tag `" + tag + "` not found");
          });
        });

        var unexpectations = (test.unexpected.tags || []).map(function(tag) {
          return db.tagExists(tag).then(function(exists) {
            assert.ok(!exists, "unexpected tag `" + tag + "` found");
          });
        });

        return Promise.all(expectations.concat(unexpectations));
      });

      assuming(
        test.expected.tags !== undefined || test.unexpected.tags !== undefined
      ).it("should meet tag existence expectations via formatTags()", function() {
        return db.numTags().then(function(count) {
          return db.formatTags(0, count);
        }).then(function(csv) {
          var tags = csv.split(",");

          (test.expected.tags || []).forEach(function(tag) {
            assert(
              tags.includes(tag),
              "expected tag `" + tag + "` not found in: (" + csv + ")"
            );
          });

          (test.unexpected.tags || []).forEach(function(tag) {
            assert(
              !tags.includes(tag),
              "unexpected tag `" + tag + "` found in: (" + csv + ")"
            );
          });
        });
      });

      assuming(
        test.expected.boxTags !== undefined || test.unexpected.boxTags !== undefined
      ).it("should record box tags correctly", function() {
        var expects = Object.keys(test.expected.boxTags || {}).map(function(box) {
          var tags = test.expected.boxTags[box];
          return db.numTagsForBox(boxID(box)).then(function(count) {
            return db.formatBoxTags(boxID(box), 0, count);
          }).then(function(csv) {
            var tags = csv.split(",");

            tags.forEach(function(tag) {
              assert(
                tags.includes(tag),
                "expected tag `" + tag + "` not found for box `" + box + "`: (" + csv + ")"
              );
            });
          });
        });

        var unexpects = Object.keys(test.unexpected.boxTags || {}).map(function(box) {
          var tags = test.unexpected.boxTags[box];
          return db.numTagsForBox(boxID(box)).then(function(count) {
            return db.formatBoxTags(boxID(box), 0, count);
          }).then(function(csv) {
            var tags = csv.split(",");

            tags.forEach(function(tag) {
              assert(
                !tags.includes(tag),
                "unexpected tag `" + tag + "` found for box `" + box + "`: (" + csv + ")"
              );
            });
          });
        });
      });
    });
  });
});
