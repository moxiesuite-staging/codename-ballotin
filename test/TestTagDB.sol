pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "../contracts/TagDB.sol";

contract TestTagDB {
  TagDB db;

  /* box1 : a b c _ _
   * box2 : _ b c d _
   * box3 : a _ c d e
   */
  bytes32 box1 = sha3("box1");  // don't are about box IDs for real
  bytes32 box2 = sha3("box2");
  bytes32 box3 = sha3("box3");

  function beforeEach() {
    db = new TagDB();
  }

  function beforeEachSetupBox1() {
    db.tagBox(box1, "a");
    db.tagBox(box1, "b");
    db.tagBox(box1, "c");
  }

  function beforeEachSetupBox2() {
    db.tagBox(box2, "b");
    db.tagBox(box2, "c");
    db.tagBox(box2, "d");
  }

  function beforeEachSetupBox3() {
    db.tagBox(box3, "a");
    db.tagBox(box3, "c");
    db.tagBox(box3, "d");
    db.tagBox(box3, "e");
  }

  function testSimpleRelationships() {
    Assert.equal(db.numTags(), 5, "There should be 5 known tags");

    Assert.isTrue(db.hasTag(box1, "a"), "box1 should have tag `a`");
    Assert.isTrue(db.hasTag(box1, "b"), "box1 should have tag `b`");
    Assert.isTrue(db.hasTag(box1, "c"), "box1 should have tag `c`");
    Assert.isFalse(db.hasTag(box1, "d"), "box1 should NOT have tag `d`");
    Assert.isFalse(db.hasTag(box1, "e"), "box1 should NOT have tag `e`");

    Assert.isFalse(db.hasTag(box2, "a"), "box2 should NOT have tag `a`");
    Assert.isTrue(db.hasTag(box2, "b"), "box2 should have tag `b`");
    Assert.isTrue(db.hasTag(box2, "c"), "box2 should have tag `c`");
    Assert.isTrue(db.hasTag(box2, "d"), "box1 should have tag `d`");
    Assert.isFalse(db.hasTag(box2, "e"), "box1 should NOT have tag `e`");

    Assert.isTrue(db.hasTag(box3, "a"), "box3 should have tag `a`");
    Assert.isFalse(db.hasTag(box3, "b"), "box3 should NOT have tag `b`");
    Assert.isTrue(db.hasTag(box3, "c"), "box3 should have tag `c`");
    Assert.isTrue(db.hasTag(box3, "d"), "box3 should have tag `d`");
    Assert.isTrue(db.hasTag(box3, "e"), "box3 should have tag `e`");
  }

  /* box1 : a b c _ _
   * box2 : _ b c d _
   * box3 : a _ c d e
   *
   * a : box1 ____ box3
   * b : box1 box2 ____
   * c : box1 box2 box3
   * d : ____ box2 box3
   * e : ____ ____ box3
   */
  function testBoxesWithTags() {
    Assert.equal(db.numBoxesWithTag("a"), 2, "2 boxes should be marked a");
    Assert.equal(db.numBoxesWithTag("b"), 2, "2 boxes should be marked b");
    Assert.equal(db.numBoxesWithTag("c"), 3, "3 boxes should be marked c");
    Assert.equal(db.numBoxesWithTag("d"), 2, "2 boxes should be marked d");
    Assert.equal(db.numBoxesWithTag("e"), 1, "1 box should be marked e");
    Assert.equal(db.numBoxesWithTag("f"), 0, "0 boxes should be marked f");

    Assert.equal(db.boxWithTagAt("a", 0), box1, "a should refer to box1");
    Assert.equal(db.boxWithTagAt("a", 1), box3, "a should refer to box3");

    Assert.equal(db.boxWithTagAt("b", 0), box1, "b should refer to box1");
    Assert.equal(db.boxWithTagAt("b", 1), box2, "b should refer to box2");

    Assert.equal(db.boxWithTagAt("c", 0), box1, "c should refer to box1");
    Assert.equal(db.boxWithTagAt("c", 1), box2, "c should refer to box2");
    Assert.equal(db.boxWithTagAt("c", 2), box3, "c should refer to box3");

    Assert.equal(db.boxWithTagAt("d", 0), box2, "d should refer to box2");
    Assert.equal(db.boxWithTagAt("d", 1), box3, "d should refer to box3");

    Assert.equal(db.boxWithTagAt("e", 0), box3, "e should refer to box3");
  }

  function testTagRemoval() {
    db.untagBox(box3, "e");

    Assert.equal(db.numBoxesWithTag("e"), 0, "e should now be unused");
    Assert.equal(db.numTags(), 4, "There should be 1 fewer tag (no more e)");
  }

  // function testUntagConsistency() {
  //   db.untagBox(box2, "d");

  //   Assert.isFalse(db.hasTag(box2, "d"), "box2 should no longer be tagged d");
  //   Assert.equal(db.numBoxesWithTag("d"), 1, "d should only be used by box3");
  //   Assert.equal(db.boxWithTagAt("d", 0), box3, "d should reference box3 at idx 0");
  // }
}
