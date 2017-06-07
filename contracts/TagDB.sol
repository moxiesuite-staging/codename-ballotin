pragma solidity ^0.4.11;

import {owned} from "./vendor/owned/owned.sol";
import {IndexedEnumerableSetLib} from "./vendor/IndexedEnumerableSetLib.sol";

/**
 * @title Database contract for tags index
 */
contract TagDB is owned {
  using IndexedEnumerableSetLib for IndexedEnumerableSetLib.IndexedEnumerableSet;

  struct TagRecord {
    string tag;

    IndexedEnumerableSetLib.IndexedEnumerableSet boxes;
  }

  /* tags collection */
  mapping (bytes32 => TagRecord) tagRecords;
  IndexedEnumerableSetLib.IndexedEnumerableSet tags;

  /* each box ID's tag collection */
  mapping (bytes32 => IndexedEnumerableSetLib.IndexedEnumerableSet) boxesTags;
  IndexedEnumerableSetLib.IndexedEnumerableSet boxes;



  /*
   * Events
   */

  event BoxTag(bytes32 indexed boxID, string indexed tag);
  event BoxUntag(bytes32 indexed boxID, string indexed tag);

  event BoxIndex(bytes32 indexed boxID);
  event BoxUnindex(bytes32 indexed boxID);

  /*
   * Read API
   */

  /* Enumerable Tags List */
  function numTags() constant returns (uint count) {
    return tags.size();
  }

  function tagAt(uint idx) constant returns (string tag) {
    return tagRecords[tags.get(idx)].tag;
  }

  function tagExists(string tag) constant returns (bool) {
    var tagHash = sha3(tag);
    return tags.contains(tagHash);
  }

  /* Box Tags List */
  function numTagsForBox(bytes32 boxID) constant returns (uint count) {
    return boxesTags[boxID].size();
  }

  function tagForBoxAt(bytes32 boxID, uint idx) constant returns (string tag) {
    var tagHash = boxesTags[boxID].get(idx);
    return tagRecords[tagHash].tag;
  }

  function boxHasTag(bytes32 boxID, string tag) constant returns (bool) {
    var tagHash = sha3(tag);
    return boxesTags[boxID].contains(tagHash);
  }

  /* Tag Boxes List */
  function numBoxesWithTag(string tag) constant returns (uint count) {
    var tagHash = sha3(tag);
    return tagRecords[tagHash].boxes.size();
  }

  function boxWithTagAt(string tag, uint idx) constant returns (bytes32 boxID) {
    var tagHash = sha3(tag);
    return tagRecords[tagHash].boxes.get(idx);
  }

  function tagHasBox(string tag, bytes32 boxID) constant returns (bool) {
    var tagHash = sha3(tag);
    return tagRecords[tagHash].boxes.contains(boxID);
  }

  /*
   * Write API
   */
  function tagBox(bytes32 boxID, string tag) onlyowner {
    var tagHash = sha3(tag);
    var record = tagRecords[tagHash];
    /* fill in tag string in case not set */
    record.tag = tag;

    bool shouldIndex = boxes.contains(boxID);

    /* add tag to box's tags */
    bool alreadyTagged;
    var boxTags = boxesTags[boxID];
    if (!boxTags.contains(tagHash)) {
      alreadyTagged = false;
      boxTags.add(tagHash);
    } else {
      alreadyTagged = true;
    }

    /* add tag to list of known tags if box is indexed */
    if (shouldIndex && !tags.contains(tagHash)) {
      tags.add(tagHash);
    }

    /* add box to list of tag's boxes if box is indexed */
    if (shouldIndex && !record.boxes.contains(boxID)) {
      record.boxes.add(boxID);
    }

    if (!alreadyTagged) {
      BoxTag(boxID, tag);
    }
  }

  function untagBox(bytes32 boxID, string tag) onlyowner {
    var tagHash = sha3(tag);
    var record = tagRecords[tagHash];

    /* remove tag from box */
    bool alreadyUntagged;
    var boxTags = boxesTags[boxID];
    if (boxTags.contains(tagHash)) {
      alreadyUntagged = false;
      boxTags.remove(tagHash);
    } else {
      alreadyUntagged = true;
    }

    /* remove box from tag record */
    if (record.boxes.contains(boxID)) {
      record.boxes.remove(boxID);
    }

    /* if tag doesn't have any boxes left, remove tag from the index */
    if (tags.contains(tagHash) && record.boxes.size() == 0) {
      tags.remove(tagHash);
    }

    if (!alreadyUntagged) {
      BoxUntag(boxID, tag);
    }
  }

  function indexBox(bytes32 boxID) onlyowner {
    if (boxes.contains(boxID)) {
      return;
    }

    boxes.add(boxID);

    var boxTags = boxesTags[boxID];
    for (var i = 0; i < boxTags.size(); i++) {
      var tagHash = boxTags.get(i);
      var record = tagRecords[tagHash];
      record.boxes.add(boxID);

      if (!tags.contains(tagHash)) { tags.add(tagHash); }
    }

    BoxIndex(boxID);
  }

  function unindexBox(bytes32 boxID) onlyowner {
    if (!boxes.contains(boxID)) {
      return;
    }

    boxes.remove(boxID);

    var boxTags = boxesTags[boxID];
    for (var i = 0; i < boxTags.size(); i++) {
      var tagHash = boxTags.get(i);
      var record = tagRecords[tagHash];

      if (record.boxes.contains(boxID)) {
        record.boxes.remove(boxID);
      }

      if (tags.contains(tagHash) && record.boxes.size() == 0) {
        tags.remove(tagHash);
      }
    }

    BoxUnindex(boxID);
  }
}
