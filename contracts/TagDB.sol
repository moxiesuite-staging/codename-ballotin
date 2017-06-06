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



  /*
   * Events
   */

  event BoxTag(bytes32 indexed boxID, string indexed tag);
  event BoxUntag(bytes32 indexed boxID, string indexed tag);

  /*
   * Read API
   */
  function numTags() constant returns (uint count) {
    return tags.size();
  }

  function tagAt(uint idx) constant returns (string tag) {
    return tagRecords[tags.get(idx)].tag;
  }

  function hasTag(bytes32 boxID, string tag) constant returns (bool) {
    var tagHash = sha3(tag);
    return boxesTags[boxID].contains(tagHash);
  }

  function numBoxesWithTag(string tag) constant returns (uint count) {
    var tagHash = sha3(tag);

    return tagRecords[tagHash].boxes.size();
  }

  function boxWithTagAt(string tag, uint idx) constant returns (bytes32 boxID) {
    var tagHash = sha3(tag);

    return tagRecords[tagHash].boxes.get(idx);
  }

  function numTagsForBox(bytes32 boxID) constant returns (uint count) {
    return boxesTags[boxID].size();
  }

  function tagForBoxAt(bytes32 boxID, uint idx) constant returns (string tag) {
    var tagHash = boxesTags[boxID].get(idx);

    return tagRecords[tagHash].tag;
  }

  /*
   * Write API
   */
  function tagBox(bytes32 boxID, string[] tags) onlyowner {
    for (var i = 0; i < tags.length; i++) {
      var tag = tags[i];
      tagBox(boxID, tag);
    }
  }

  function tagBox(bytes32 boxID, string tag) onlyowner {
    var tagHash = sha3(tag);
    var record = tagRecords[tagHash];
    bool alreadyTagged;

    /* fill in tag string in case not set */
    record.tag = tag;

    /* ensure tag is in list of known tags */
    if (!tags.contains(tagHash)) { tags.add(tagHash); }

    /* add tag to box's tags, add box to tag's boxes */
    var boxTags = boxesTags[boxID];
    if (!boxTags.contains(tagHash)) {
      alreadyTagged = false;
      boxTags.add(tagHash);
      record.boxes.add(boxID);
    } else {
      alreadyTagged = true;
    }

    if (!alreadyTagged) {
      BoxTag(boxID, tag);
    }
  }

  function untagBox(bytes32 boxID, string tag) onlyowner {
    var tagHash = sha3(tag);
    var record = tagRecords[tagHash];
    bool alreadyUntagged;

    /* remove pair relationships: box's tags and tag's boxes */
    var boxTags = boxesTags[boxID];
    if (boxTags.contains(tagHash)) {
      alreadyUntagged = false;
      boxTags.remove(tagHash);
      record.boxes.remove(boxID);
    } else {
      alreadyUntagged = true;
    }

    /* if tag doesn't have any boxes left, remove tag from the index */
    if (tags.contains(tagHash) && record.boxes.size() == 0) {
      tags.remove(tagHash);
    }

    if (!alreadyUntagged) {
      BoxUntag(boxID, tag);
    }
  }
}
