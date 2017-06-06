pragma solidity ^0.4.11;

import {owned} from "./vendor/owned/owned.sol";
import {IndexedEnumerableSetLib} from "./vendor/IndexedEnumerableSetLib.sol";

/**
 * @title Database contract for Truffle Box package data
 */
contract BoxDB is owned {
  using IndexedEnumerableSetLib for IndexedEnumerableSetLib.IndexedEnumerableSet;

  struct BoxRecord {
    address maintainer;
    string summary;
    string description;
    string sourceURL;

    uint addedAt;
    uint updatedAt;
  }

  /* underlying data */
  mapping (bytes32 => BoxRecord) boxRecords;

  /* public (approved) index */
  IndexedEnumerableSetLib.IndexedEnumerableSet boxes;


  /*
   * Events
   */
  event BoxCreate(bytes32 indexed id);
  event BoxUpdate(bytes32 indexed id);

  event BoxAdd(bytes32 indexed id);
  event BoxRemove(bytes32 indexed id);

  /*
   * Modifiers
   */
  modifier onlyIfBoxExists(bytes32 id) {
    if (!boxExists(id)) {
      throw;
    }

    _;
  }

  modifier onlyIfBoxIndexed(bytes32 id) {
    if (!boxIndexed(id)) {
      throw;
    }

    _;
  }

  /*
   * Read API
   */
  function boxExists(bytes32 id) constant returns (bool) {
    return boxRecords[id].addedAt > 0;
  }

  function boxIndexed(bytes32 id) constant returns (bool) {
    return boxes.contains(id);
  }

  function numBoxes() constant returns (uint) {
    return boxes.size();
  }

  function boxAt(uint idx) constant returns (bytes32 id) {
    return boxes.get(idx);
  }

  function boxInfo(bytes32 id)
    onlyIfBoxExists(id)
    constant
    returns (
      string summary,
      string description,
      string sourceURL,
      address maintainer,
      uint addedAt,
      uint updatedAt
  ) {
    var record = boxRecords[id];

    return (
      record.summary,
      record.description,
      record.sourceURL,
      record.maintainer,
      record.addedAt,
      record.updatedAt
    );
  }

  function boxID(address maintainer, string sourceURL, uint salt) constant returns (bytes32) {
    return sha3(maintainer, sourceURL, salt);
  }

  /*
   * Write API
   */
  function create(
    string summary,
    string description,
    string sourceURL,
    address maintainer
  ) onlyowner returns (bytes32 id) {

    id = boxID(maintainer, sourceURL, block.number);
    if (boxExists(id)) {
      throw;
    }

    var record = boxRecords[id];

    record.summary = summary;
    record.description = description;
    record.sourceURL = sourceURL;
    record.maintainer = maintainer;
    record.addedAt = now;
    record.updatedAt = now;

    BoxCreate(id);
  }

  function update(
    bytes32 id,
    string summary,
    string description,
    string sourceURL,
    address maintainer
  ) onlyowner onlyIfBoxExists(id) {
    var record = boxRecords[id];

    record.summary = summary;
    record.description = description;
    record.sourceURL = sourceURL;
    record.maintainer = maintainer;

    record.updatedAt = now;

    BoxUpdate(id);
  }

  function add(bytes32 id) onlyowner onlyIfBoxExists(id) {
    if (!boxes.contains(id)) {
      boxes.add(id);

      BoxAdd(id);
    }
  }

  function remove(bytes32 id) onlyIfBoxExists(id) onlyowner {
    boxes.remove(id);

    BoxRemove(id);
  }
}
