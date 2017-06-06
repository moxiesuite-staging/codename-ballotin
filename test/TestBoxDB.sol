pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "../contracts/BoxDB.sol";

contract MaintainerProxy {
}

contract TestBoxDB {
  BoxDB db;

  function beforeEach() {
    db = new BoxDB();
  }

  function testAddingBox() {
    var summary = "test box";
    var description = "longer description";
    var sourceURL = "git+ssh://git@github.com:truffle-box/truffle-box-react.git";
    MaintainerProxy proxy = new MaintainerProxy();

    var numBoxesPrior = db.numBoxes();

    var boxID = db.add(summary, description, sourceURL, address(proxy));

    /* existence */
    Assert.isTrue(db.boxExists(boxID), "Box should exist after being added");
    Assert.equal(db.numBoxes(), numBoxesPrior + 1, "Box count should be increased by one");
    Assert.equal(db.boxAt(numBoxesPrior), boxID, "Box ID should be enumerated");

    /* correctness (string returns don't work, skip for test) */
    var (_0, _1, _2, maintainer, addedAt, updatedAt) = db.boxInfo(boxID);
    Assert.equal(maintainer, address(proxy), "Maintainer should match");
    Assert.isAbove(addedAt, 0, "Add time should be set");
    Assert.isAbove(updatedAt, 0, "Update time should be set");
  }

  function testUpdatingBox() {
    /* add first */
    var summary = "test box";
    var description = "longer description";
    var sourceURL = "git+ssh://git@github.com:truffle-box/truffle-box-react.git";
    var maintainer = address(new MaintainerProxy());
    var boxID = db.add(summary, description, sourceURL, maintainer);

    /* update */
    var newMaintainer = address(new MaintainerProxy());
    db.update(boxID, "new summary", "new desc", sourceURL, newMaintainer);

    var (_0, _1, _2, updatedMaintainer, _3, _4) = db.boxInfo(boxID);
    Assert.equal(updatedMaintainer, newMaintainer, "Maintainer should change");
  }

  function testRemovingBox() {
    /* add first */
    var summary = "test box";
    var description = "longer description";
    var sourceURL = "git+ssh://git@github.com:truffle-box/truffle-box-react.git";
    var maintainer = address(new MaintainerProxy());
    var boxID = db.add(summary, description, sourceURL, maintainer);

    var numBoxesPrior = db.numBoxes();

    /* update */
    db.remove(boxID);

    Assert.equal(db.numBoxes(), numBoxesPrior - 1, "Number of boxes should decrease");
  }
}
