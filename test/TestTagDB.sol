pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "../contracts/vendor/strings.sol";
import "../contracts/TagDB.sol";

library TagTest {
  using strings for *;

  struct TestCase {
    TagDB db;
    string id;
  }

  function setup(TagDB db, string id)
    internal
    returns (TestCase memory test)
  {
    test.db = db;
    test.id = id;
  }

  function expectTag(TestCase test, string tag, bool expected) internal {
    bool exists = test.db.tagExists(tag);

    var expectation = "TO BE in tags list";
    if (!expected) {
      expectation = "NOT ".toSlice().concat(expectation.toSlice());
    }

    var actuality = "FOUND";
    if (!exists) {
      actuality = "NOT ".toSlice().concat(actuality.toSlice());
    }

    if (expected != exists) {
      var message = "Expected tag `";
      message = message.toSlice().concat(tag.toSlice());
      message = message.toSlice().concat("` ".toSlice());
      message = message.toSlice().concat(expectation.toSlice());
      message = message.toSlice().concat(", ".toSlice());
      message = message.toSlice().concat(actuality.toSlice());
      message = message.toSlice().concat(". (test id: ".toSlice());
      message = message.toSlice().concat(test.id.toSlice());
      message = message.toSlice().concat(")".toSlice());

      Assert.fail(message);
    }
  }

  function expectBoxTag(
    TestCase test,
    bytes32 boxID,
    string tag,
    bool expected,
    string boxHint
  )
    internal
  {
    bool hasTag = test.db.boxHasTag(boxID, tag);

    var expectation = "TO BE in tags list for box";
    if (!expected) {
      expectation = "NOT ".toSlice().concat(expectation.toSlice());
    }

    var actuality = "FOUND";
    if (!hasTag) {
      actuality = "NOT ".toSlice().concat(actuality.toSlice());
    }

    if (expected != hasTag) {
      var message = "Expected tag `";
      message = message.toSlice().concat(tag.toSlice());
      message = message.toSlice().concat("` ".toSlice());
      message = message.toSlice().concat(expectation.toSlice());
      message = message.toSlice().concat(" `".toSlice());
      message = message.toSlice().concat(boxHint.toSlice());
      message = message.toSlice().concat("`, ".toSlice());
      message = message.toSlice().concat(actuality.toSlice());
      message = message.toSlice().concat(". (test id: ".toSlice());
      message = message.toSlice().concat(test.id.toSlice());
      message = message.toSlice().concat(")".toSlice());

      Assert.fail(message);
    }
  }

  function expectTagBox(
    TestCase test,
    string tag,
    bytes32 boxID,
    bool expected,
    string boxHint
  )
    internal
  {
    bool hasBox = test.db.tagHasBox(tag, boxID);

    var expectation = "TO BE in boxes list for tag";
    if (!expected) {
      expectation = "NOT ".toSlice().concat(expectation.toSlice());
    }

    var actuality = "FOUND";
    if (!hasBox) {
      actuality = "NOT ".toSlice().concat(actuality.toSlice());
    }

    if (expected != hasBox) {
      var message = "Expected box `";
      message = message.toSlice().concat(boxHint.toSlice());
      message = message.toSlice().concat("` ".toSlice());
      message = message.toSlice().concat(expectation.toSlice());
      message = message.toSlice().concat(" `".toSlice());
      message = message.toSlice().concat(tag.toSlice());
      message = message.toSlice().concat("`, ".toSlice());
      message = message.toSlice().concat(actuality.toSlice());
      message = message.toSlice().concat(". (test id: ".toSlice());
      message = message.toSlice().concat(test.id.toSlice());
      message = message.toSlice().concat(")".toSlice());

      Assert.fail(message);
    }
  }
}

contract TestTagDB {
  using TagTest for TagTest.TestCase;

  TagDB db;

  bytes32 box1 = sha3("box1");  // don't are about box IDs for real
  bytes32 box2 = sha3("box2");
  bytes32 box3 = sha3("box3");

  string tagA = "a";
  string tagB = "b";
  string tagC = "c";


  function beforeEach() {
    db = new TagDB();
  }

  function testTaggingAfterIndex() {
    TagTest.TestCase memory test = TagTest.setup(db, "taggingAfterIndex");

    db.indexBox(box1);
    db.tagBox(box1, tagA);

    test.expectBoxTag(box1, tagA, true, "box1");
    test.expectTag(tagA, true);
    test.expectTagBox(tagA, box1, true, "box1");
  }

  function testTaggingBeforeIndex() {
    TagTest.TestCase memory test = TagTest.setup(db, "taggingBeforeIndex");

    db.tagBox(box1, tagA);
    db.indexBox(box1);

    test.expectBoxTag(box1, tagA, true, "box1");
    test.expectTag(tagA, true);
    test.expectTagBox(tagA, box1, true, "box1");
  }

  function testTaggingNoIndex() {
    TagTest.TestCase memory test = TagTest.setup(db, "taggingNoIndex");

    db.tagBox(box1, tagA);

    test.expectBoxTag(box1, tagA, true, "box1");
    test.expectTag(tagA, false);
    test.expectTagBox(tagA, box1, false, "box1");
  }

  function testUnindexing() {
    TagTest.TestCase memory test = TagTest.setup(db, "unindexing");

    db.indexBox(box1);
    db.tagBox(box1, tagA);
    db.unindexBox(box1);

    test.expectTag(tagA, false);
    test.expectTagBox(tagA, box1, false, "box1");
  }
}
