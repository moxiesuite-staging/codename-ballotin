pragma solidity ^0.4.11;

import {owned} from "./vendor/owned/owned.sol";
import {IndexedEnumerableSetLib} from "./vendor/IndexedEnumerableSetLib.sol";

/**
 * @title Database contract for tags index
 */
contract TagDB is owned {
  using IndexedEnumerableSetLib for IndexedEnumerableSetLib.IndexedEnumerableSet;

  /* tags collection */
  mapping (bytes32 => IndexedEnumerableSetLib.IndexedEnumerableSet) tagsBoxes;
  IndexedEnumerableSetLib.IndexedEnumerableSet tags;

  /* each box ID's tag collection */
  mapping (bytes32 => IndexedEnumerableSetLib.IndexedEnumerableSet) boxesTags;
  IndexedEnumerableSetLib.IndexedEnumerableSet boxes;



  /*
   * Events
   */

  event BoxTag(bytes32 boxID, bytes32 tag);
  event BoxUntag(bytes32 boxID, bytes32 tag);

  event BoxIndex(bytes32 boxID);
  event BoxUnindex(bytes32 boxID);

  /*
   * Read API
   */

  /* Enumerable Tags List */
  function numTags() constant returns (uint count) {
    return tags.size();
  }

  function tagAt(uint idx) constant returns (bytes32 tag) {
    return tags.get(idx);
  }

  function tagExists(bytes32 tag) constant returns (bool) {
    return tags.contains(tag);
  }

  /* Box Tags List */
  function numTagsForBox(bytes32 boxID) constant returns (uint count) {
    return boxesTags[boxID].size();
  }

  function tagForBoxAt(bytes32 boxID, uint idx) constant returns (bytes32 tag) {
    return boxesTags[boxID].get(idx);
  }

  function boxHasTag(bytes32 boxID, bytes32 tag) constant returns (bool) {
    return boxesTags[boxID].contains(tag);
  }

  /* Tag Boxes List */
  function numBoxesWithTag(bytes32 tag) constant returns (uint count) {
    return tagsBoxes[tag].size();
  }

  function boxWithTagAt(bytes32 tag, uint idx) constant returns (bytes32 boxID) {
    return tagsBoxes[tag].get(idx);
  }

  function tagHasBox(bytes32 tag, bytes32 boxID) constant returns (bool) {
    return tagsBoxes[tag].contains(boxID);
  }

  /*
   * Write API
   */
  function tagBox(bytes32 boxID, bytes32 tag) onlyowner {
    bool shouldIndex = boxes.contains(boxID);

    /* add tag to box's tags */
    bool alreadyTagged;
    var boxTags = boxesTags[boxID];
    if (!boxTags.contains(tag)) {
      alreadyTagged = false;
      boxTags.add(tag);
    } else {
      alreadyTagged = true;
    }

    /* add tag to list of known tags if box is indexed */
    if (shouldIndex && !tags.contains(tag)) {
      tags.add(tag);
    }

    /* add box to list of tag's boxes if box is indexed */
    var tagBoxes = tagsBoxes[tag];
    if (shouldIndex && !tagBoxes.contains(boxID)) {
      tagBoxes.add(boxID);
    }

    if (!alreadyTagged) {
      BoxTag(boxID, tag);
    }
  }

  function untagBox(bytes32 boxID, bytes32 tag) onlyowner {
    var tagBoxes = tagsBoxes[tag];

    /* remove tag from box */
    bool alreadyUntagged;
    var boxTags = boxesTags[boxID];
    if (boxTags.contains(tag)) {
      alreadyUntagged = false;
      boxTags.remove(tag);
    } else {
      alreadyUntagged = true;
    }

    /* remove box from tag record */
    if (tagBoxes.contains(boxID)) {
      tagBoxes.remove(boxID);
    }

    /* if tag doesn't have any boxes left, remove tag from the index */
    if (tags.contains(tag) && tagBoxes.size() == 0) {
      tags.remove(tag);
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
      var tag = boxTags.get(i);

      tagsBoxes[tag].add(boxID);
      if (!tags.contains(tag)) { tags.add(tag); }
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
      var tag = boxTags.get(i);
      var tagBoxes = tagsBoxes[tag];

      if (tagBoxes.contains(boxID)) {
        tagBoxes.remove(boxID);
      }

      if (tags.contains(tag) && tagBoxes.size() == 0) {
        tags.remove(tag);
      }
    }

    BoxUnindex(boxID);
  }
}
