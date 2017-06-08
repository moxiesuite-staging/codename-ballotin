pragma solidity ^0.4.11;

import "../contracts/TagDB.sol";
import "truffle/Assert.sol";

contract TestTagDB {
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
    db.indexBox(box1);
    db.tagBox(box1, tagA);

    Assert.equal(db.boxHasTag(box1, tagA), true, "box should have tag");
    Assert.equal(db.tagExists(tagA), true, "tag should exist");
    Assert.equal(db.tagHasBox(tagA, box1), true, "tag should have box");
  }

  function testTaggingBeforeIndex() {
    db.tagBox(box1, tagA);
    db.indexBox(box1);

    Assert.equal(db.boxHasTag(box1, tagA), true, "box should have tag");
    Assert.equal(db.tagExists(tagA), true, "tag should exist");
    Assert.equal(db.tagHasBox(tagA, box1), true, "tag should have box");
  }

  function testTaggingNoIndex() {
    db.tagBox(box1, tagA);

    Assert.equal(db.boxHasTag(box1, tagA), true, "box should have tag");
    Assert.equal(db.tagExists(tagA), false, "tag should NOT exist");
    Assert.equal(db.tagHasBox(tagA, box1), false, "tag should NOT have box");
  }

  function testUnindexing() {
    db.indexBox(box1);
    db.tagBox(box1, tagA);
    db.unindexBox(box1);

    Assert.equal(db.tagExists(tagA), false, "tag should NOT exist");
    Assert.equal(db.tagHasBox(tagA, box1), false, "tag should NOT have box");
  }
}
