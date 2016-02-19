import extend from './extend.jsx';

let CwicGranule = (function() {
  extend(CwicGranule, window.edsc.models.data.Granule);

  function CwicGranule(jsonData) {
    CwicGranule.__super__.constructor.apply(this, Array.prototype.slice.call(arguments));
  }

  CwicGranule.prototype.edsc_browse_url = function(w, h) {
    for (var i = 0; i < this.links.length; i ++) {
      if (this.links[i].rel == 'icon') {
        return this.links[i].href;
      }
    }
    return null;
  };

  CwicGranule.prototype.edsc_full_browse_url = function() {
    // This is kind of a hack because CWIC does not have a standard link relation
    // for large-sized browse, so we look for URLs with extensions of jpg, jpeg,
    // gif, and png, and return the first one which is not marked as the icon.
    // If there's no such relation, we return nothing, which results in there being
    // no link to the full size image.
    for (var i = 0; i < this.links.length; i ++) {
      var href = this.links[i].href;
      if (this.links[i].rel != 'icon' && href.match(/\.(?:gif|jpg|jpeg|png)(?:\?|#|$)/)) {
        return href;
      }
    }
    return null;
  };


  CwicGranule.prototype.getTemporal = function () {
    if (typeof this.date !== "undefined" && this.date !== null) {
      var temporal = this.date.split("/");
      var time_start, time_end;
      time_start = temporal[0];
      time_end = temporal[1];

      if (time_start === time_end) {
        return time_start;
      }
      if (time_end == null) {
        return time_start;
      }
      if (time_start == null) {
        return time_end;
      }
      return "" + time_start + " to " + time_end;
    }
    return null;
  };

  return CwicGranule;
})();


export default CwicGranule;