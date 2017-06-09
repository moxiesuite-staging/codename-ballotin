pragma solidity ^0.4.11;

import {owned} from "./vendor/owned/owned.sol";

import {BoxDB} from "./BoxDB.sol";
import {TagDB} from "./TagDB.sol";

contract Registry is owned {
  BoxDB public boxes;
  TagDB public tags;


  function Registry() {
    boxes = new BoxDB();
    tags = new TagDB();
  }

  /*
   * Modifiers
   */
  modifier onlyMaintainer(bytes32 boxID) {
    if (boxes.boxMaintainer(boxID) != msg.sender) {
      throw;
    }
    _;
  }

  /*
   * Maintainer API
   */
  function createBox(
    string summary,
    string description,
    string sourceURL
  ) returns (bytes32 boxID) {
    return boxes.create(summary, description, sourceURL, msg.sender);
  }

  function updateBox(
    bytes32 boxID,
    string summary,
    string description,
    string sourceURL
  ) onlyMaintainer(boxID) {
    boxes.update(boxID, summary, description, sourceURL, msg.sender);
  }

  function tagBox(bytes32 boxID, string tag) onlyMaintainer(boxID) {
    tags.tagBox(boxID, tag);
  }

  function untagBox(bytes32 boxID, string tag) onlyMaintainer(boxID) {
    tags.untagBox(boxID, tag);
  }

  /*
   * Truffle Organization API
   */
  function approveBox(bytes32 boxID) onlyowner {
    boxes.add(boxID);
    tags.indexBox(boxID);
  }

  function deapproveBox(bytes32 boxID) onlyowner {
    boxes.remove(boxID);
    tags.unindexBox(boxID);
  }
}
