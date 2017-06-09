pragma solidity ^0.4.11;

import {IndexedEnumerableSetLib as SetLib} from "./vendor/IndexedEnumerableSetLib.sol";
import "../contracts/vendor/strings.sol";

library FormatLib {
  using SetLib for SetLib.IndexedEnumerableSet;
  using strings for *;

  function format(
    SetLib.IndexedEnumerableSet storage self,
    function (bytes32) internal constant returns (string) lookup,
    uint start, uint max
  )
    internal
    constant
    returns (string csv)
  {
    if (self.size() <= start || max == 0) {
      return "";
    }

    var upper = max + start;  // first index exceeding bound
    if (self.size() < upper) {
      upper = self.size();
    }

    csv = lookup(self.get(start));
    for (var i = start + 1; i < upper; i++) {
      var item = lookup(self.get(i));
      csv = csv.toSlice().concat(",".toSlice());
      csv = csv.toSlice().concat(item.toSlice());
    }
  }
}
