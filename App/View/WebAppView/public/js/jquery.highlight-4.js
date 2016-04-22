/*

highlight v4

Highlights arbitrary terms.

<http://johannburkard.de/blog/programming/javascript/highlight-javascript-text-higlighting-jquery-plugin.html>

MIT license.

Johann Burkard
<http://johannburkard.de>
<mailto:jb@eaio.com>

 */

jQuery.fn.highlight = function(pattern) {
    
	var firstHighlightedSpan;
	var firstHighlightedSpanVisible = true;
    
	function innerHighlight(node, pat) {
		var skip = 0;
		if (node.nodeType == 3) {
			var pos = node.data.toUpperCase().indexOf(pat);
			if (pos >= 0) {
				var spannode = document.createElement('span');
				spannode.className = 'highlight';
				var middlebit = node.splitText(pos);
				var endbit = middlebit.splitText(pat.length);
				var middleclone = middlebit.cloneNode(true);
				spannode.appendChild(middleclone);
				middlebit.parentNode.replaceChild(spannode, middlebit);
				if (!firstHighlightedSpan) {
					firstHighlightedSpan = spannode;
					firstHighlightedSpanVisible = jQuery(spannode).is(':visible');
				}
				skip = 1;
			}
		} else if (node.nodeType == 1 && node.childNodes && !/(script|style)/i.test(node.tagName)) {
			for ( var i = 0; i < node.childNodes.length; ++i) {
				i += innerHighlight(node.childNodes[i], pat);
			}
		}
		return skip;
	}

	if (this.length && pattern && pattern.length) {
		var that = this;
		jQuery.each(pattern.toUpperCase().split(/\s+/g), function(idx, pat) {
			that.each(function() {
				innerHighlight(this, pat);
			});
		})

		if (firstHighlightedSpan) {
			if (!firstHighlightedSpanVisible)
				jQuery.expandContainers(firstHighlightedSpan);
			firstHighlightedSpan.scrollIntoView(false);
		}
	}
	return this;
};

jQuery.fn.removeHighlight = function() {
	return this.find("span.highlight").each(function() {
		this.parentNode.firstChild.nodeName;
		with (this.parentNode) {
			replaceChild(this.firstChild, this);
			normalize();
		}
	}).end();
};

jQuery.fn.expandContainers = function(elem) {
    
    function expandAux(elem) {
    
        if (jQuery(elem).closest("div.accordion-body:not(.in)").length > 0) {
            jQuery(elem).closest("div.accordion-group").find( "a.accordion-toggle").trigger('click');
            expandAux(jQuery(elem).closest("div.accordion-group").parent());
        }
        if (jQuery(elem).closest("div.tab-pane:not(.active)").length > 0) {
            var id = jQuery(elem).closest("div.tab-pane:not(.active)").attr('id');
            var parent = jQuery(elem).closest("div.tabs,div.tabbable");
            if(parent.length > 0) {
                parent.find( "ul.nav.nav-tabs li a[data-toggle='tab'][href='#" + id + "']").trigger('click');
                expandAux(parent.parent());
            }
        }
    }
    
    expandAux(elem);
};
