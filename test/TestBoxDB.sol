pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "../contracts/BoxDB.sol";

contract MaintainerProxy {
}

contract TestBoxDB {
  BoxDB db;

  string exampleSummary = "truffle-box-react";
  string exampleDescription = "Truffle Box preconfigured with React integration";
  string exampleSourceURL = "git+ssh://git@github.com:truffle-box/truffle-box-react.git";

  struct TestCase {
    string summary;
    string description;
    string sourceURL;
    MaintainerProxy maintainerProxy;

    bytes32 boxID;
    uint numBoxesBefore;
  }

  function setupTestCase(MaintainerProxy maintainer)
    internal
    returns (TestCase memory test)
  {
    test.summary = exampleSummary;
    test.description = exampleDescription;
    test.sourceURL = exampleSourceURL;
    test.maintainerProxy = maintainer;

    test.numBoxesBefore = db.numBoxes();
  }

  function createBox(TestCase test) internal {
    test.boxID = db.create(
      test.summary,
      test.description,
      test.sourceURL,
      address(test.maintainerProxy)
    );
  }

  function beforeEach() {
    db = new BoxDB();
  }

  function testCreatingBox() {
    TestCase memory test = setupTestCase(new MaintainerProxy());
    createBox(test);

    /* existence */
    Assert.isTrue(db.boxExists(test.boxID), "Box should exist after being added");

    /* correctness (string returns don't work, skip for test) */
    var (_0, _1, _2, maintainer, addedAt, updatedAt) = db.boxInfo(test.boxID);
    Assert.equal(maintainer, address(test.maintainerProxy), "Maintainer should match");
    Assert.isAbove(addedAt, 0, "Add time should be set");
    Assert.isAbove(updatedAt, 0, "Update time should be set");
  }

  function testAddingBox() {
    TestCase memory test = setupTestCase(new MaintainerProxy());
    createBox(test);

    db.add(test.boxID);
    Assert.equal(db.numBoxes(), test.numBoxesBefore + 1, "Box count should be increased by one");
    Assert.equal(db.boxAt(test.numBoxesBefore), test.boxID, "Box ID should be enumerated");
  }

  function testUpdatingBox() {
    TestCase memory test = setupTestCase(new MaintainerProxy());
    createBox(test);
    db.add(test.boxID);

    /* update */
    var newMaintainer = address(new MaintainerProxy());
    db.update(test.boxID, "new summary", "new desc", test.sourceURL, newMaintainer);

    var (_0, _1, _2, updatedMaintainer, _3, _4) = db.boxInfo(test.boxID);
    Assert.equal(updatedMaintainer, newMaintainer, "Maintainer should change");
  }

  function testRemovingBox() {
    TestCase memory test = setupTestCase(new MaintainerProxy());
    createBox(test);
    db.add(test.boxID);

    /* pre-flight check */
    Assert.equal(db.numBoxes(), test.numBoxesBefore + 1, "Box count should go up after add");

    /* remove */
    db.remove(test.boxID);

    Assert.equal(db.numBoxes(), test.numBoxesBefore, "Box count should go down after remove");
  }
}
