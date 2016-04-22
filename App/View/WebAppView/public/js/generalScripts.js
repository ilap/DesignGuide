//Invoked from CMS as well, so use jQuery not $
function showMore(attrName) {
	var expanded = parseInt(jQuery(this).attr("expanded"));
	var that = this;
	var gpId = jQuery(this).attr(attrName);
	var container = jQuery(".showMoreOverflowId[" + attrName + "='" + gpId + "']");
	var tableHeight = jQuery(".showMoreOverflowId[" + attrName + "='" + gpId + "'] table").height();
	var animationTime = Math.min(1000, tableHeight - 200);
	
	if(!expanded) {
		jQuery(container).animate({
    		"max-height" : tableHeight,
    		}, animationTime, function() {
    			jQuery(that).html('<i class="fa-angle-double-up"></i> Show less');
    		}
    	);
    	
		jQuery(this).attr("expanded", 1);
	} else {
		jQuery(container).animate({
    		"max-height" : 200,
			}, animationTime, function() {
				jQuery(that).html('<i class="fa-angle-double-down"></i> Show more');
    		}
    	);
    	
		jQuery(this).attr("expanded", 0);
	}
}

function bezierDelete(sourceElement, destinationElement, elementToHide, hideElement, reloadPage) {
	// default to true
	hideElement = typeof hideElement !== 'undefined' ? hideElement : true;
	
	// add the folder close there delete button is at
	var icon = jQuery(document.createElement("i"));
	jQuery(icon).addClass("fa-folder");
	jQuery(icon).addClass("icon-absolute");
	jQuery(icon).css("left", jQuery(sourceElement).offset().left + jQuery(sourceElement).outerWidth() / 2 - 8);
	jQuery(icon).css("top", jQuery(sourceElement).offset().top - 16);
	
	jQuery("body").append(icon);
	var bezier_params = {
		start: {
			x: jQuery(icon).offset().left,
			y: jQuery(icon).offset().top,
			angle: 60
			//length: 1.5
		},
		end: {
			x: jQuery(destinationElement).offset().left + jQuery(destinationElement).outerWidth() / 2 - 8,
			y: jQuery(destinationElement).offset().top + jQuery(destinationElement).outerHeight() / 2 - 8,
			angle: -90,
			length: .5
		}
	};
	
	
	jQuery(icon).animate({
		path: new jQuery.path.bezier(bezier_params)
	}, 1000, function() {
		if(hideElement) {
			jQuery(elementToHide).fadeOut(1000, function() {
				jQuery(icon).remove();
			});
		} else {
			jQuery(icon).remove();
		}
		
		if(reloadPage) {
			location.reload(true);
		}
	});
}

/******** Function to place the cursor at a position  or select a range in a textarea/textfield.
 * Function also for getting the position or selection range                        ***********/
(function (jQuery, undefined) {
	jQuery.fn.getCursorPosition = function() {
        var el = jQuery(this).get(0);
        var pos = 0;
        if('selectionEnd' in el) {
            pos = el.selectionEnd;
        } else if('selection' in document) {
            el.focus();
            var Sel = document.selection.createRange();
            var SelLength = document.selection.createRange().text.length;
            Sel.moveStart('character', -el.value.length);
            pos = Sel.text.length - SelLength;
        }
        return pos;
    }
})(jQuery);

(function (jQuery, undefined) {
	jQuery.fn.getSelectionRange = function () {
    	var el = jQuery(this).get(0);
        var start = 0, end = 0, normalizedValue, range,
        textInputRange, len, endRange;

    if (typeof el.selectionStart == "number" && typeof el.selectionEnd == "number") {
        start = el.selectionStart;
        end = el.selectionEnd;
    } else {
        range = document.selection.createRange();

        if (range && range.parentElement() == el) {
            len = el.value.length;
            normalizedValue = el.value.replace(/\r\n/g, "\n");

            // Create a working TextRange that lives only in the input
            textInputRange = el.createTextRange();
            textInputRange.moveToBookmark(range.getBookmark());

            // Check if the start and end of the selection are at the very end
            // of the input, since moveStart/moveEnd doesn't return what we want
            // in those cases
            endRange = el.createTextRange();
            endRange.collapse(false);

            if (textInputRange.compareEndPoints("StartToEnd", endRange) > -1) {
                start = end = len;
            } else {
                start = -textInputRange.moveStart("character", -len);
                start += normalizedValue.slice(0, start).split("\n").length - 1;

                if (textInputRange.compareEndPoints("EndToEnd", endRange) > -1) {
                    end = len;
                } else {
                    end = -textInputRange.moveEnd("character", -len);
                    end += normalizedValue.slice(0, end).split("\n").length - 1;
                }
            }
        }
    }

    return {
        start: start,
        end: end
    };
}
})(jQuery);

(function (jQuery, undefined) {
	jQuery.fn.setSelectionRange = function( selectionStart, selectionEnd) {
		var input = jQuery(this).get(0);
		if (input.setSelectionRange) {
			input.focus();
			input.setSelectionRange(selectionStart, selectionEnd);
		}
		else if (input.createTextRange) {
			var range = input.createTextRange();
			range.collapse(true);
			range.moveEnd('character', selectionEnd);
			range.moveStart('character', selectionStart);
			range.select();
		}
	}
})(jQuery);

(function (jQuery, undefined) {
	jQuery.fn.setCursorPosition = function( pos) {
		jQuery(this).setSelectionRange( pos, pos);
	}
})(jQuery);

/*********        End of cursor functions              **********/

function waitAndCall(fn, args, waitTime) {
	if(fn) {
		if(waitTime === undefined)
			waitTime = 100;
		else if(waitTime <= 0)
			return;
		window[fn] ? window[fn].apply(null, args) : setTimeout( function() { waitAndCall.call(null, fn, args, waitTime - 100) }, 100);
	}
}

function numbersOnly() {
	var replaced = this.value.replace(/[^0-9]/g, '');
	if (this.value != replaced) {
       this.value = replaced;
    }
}

jQuery(function() {
	//Prevent submitting forms multiple times
	jQuery("form.prevent-double-click-submit").on('submit', function(e){
		var form = jQuery(this);
		
		if (form.data('submitted') === true) {
		  // Previously submitted - don't submit again
		  e.preventDefault();
		} else {
		  // Mark it so that the next submit can be ignored
		  form.data('submitted', true);
		}
	});
	
	jQuery(document).on('click', '.disable-on-click', function(){
		jQuery(this).prop('disabled', true);
    	window.location.href = jQuery(this).attr('data');
    });

	//Scrollable: from http://stackoverflow.com/questions/16323770/stop-page-from-scrolling-if-hovering-div
	jQuery('.modal-body,.scrollable').on('DOMMouseScroll mousewheel', function(ev) {
	    var $this = jQuery(this),
	        scrollTop = this.scrollTop,
	        scrollHeight = this.scrollHeight,
	        height = $this.height(),
	        delta = (ev.type == 'DOMMouseScroll' ?
	            ev.originalEvent.detail * -40 :
	            ev.originalEvent.wheelDelta),
	        up = delta > 0;
	
	    var prevent = function() {
	        ev.stopPropagation();
	        ev.preventDefault();
	        ev.returnValue = false;
	        return false;
	    }
	    
	    if (!up && -delta > scrollHeight - height - scrollTop) {
	        // Scrolling down, but this will take us past the bottom.
	        $this.scrollTop(scrollHeight);
	        return prevent();
	    } else if (up && delta > scrollTop) {
	        // Scrolling up, but this will take us past the top.
	        $this.scrollTop(0);
	        return prevent();
	    }
	});
	
	//Numbers only
	jQuery('.numbersOnly').keyup(numbersOnly);
	jQuery(document).on('paste', '.numbersOnly', function() {
		var that = jQuery(this);
		setTimeout(function(){
			numbersOnly.call(that);
		},50);
	});
	
	jQuery(document).on("draw.dt", ".dataTable", function() {
		jQuery(this).find("th").find("i.fa-sort,i.fa-sort-up,i.fa-sort-down").remove();
		jQuery(this).find("th.sorting").append("<i class='fa fa-sort'></i>");
		jQuery(this).find("th.sorting_asc").append("<i class='fa fa-sort-up'></i>");
		jQuery(this).find("th.sorting_desc").append("<i class='fa fa-sort-down'></i>");
		//jQuery(this).find("th.sorting_asc_disabled").append("<img class='sort-icon' src='/eCommerce/resources/css/images/sort_asc_disabled.png'/>");
		//jQuery(this).find("th.sorting_desc_disabled").append("<img class='sort-icon' src='/eCommerce/resources/css/images/sort_desc_disabled.png'/>");
	});
	
	jQuery("table.dna2-data-table").each(function() {
		initDataTables.call(this);
	});
});

function initDataTables() {
	var table = jQuery(this);
	var columnSort = new Array;
	var options = {
		paging: table.attr("data-table-paging") == "true",
		searching: table.attr("data-table-searching") == "true",
	    ordering:  table.attr("data-table-ordering") == "true",
	    order: []
	}
	//Sorting disabled for any columns?
	table.find("thead th").each(function(idx){
		if(jQuery(this).attr('data-table-ordering') !== 'true') {
            columnSort.push(idx);
        }
	});
	//If not disabled on any column, enable it on all
	if(table.find("thead th").length > columnSort.length) {
		options.columnDefs = [{orderable: false, targets: columnSort}];
	}
	table.on("init.dt", function() {
		//Remove paging and searching divs if not used
		if(!table.attr("data-table-paging") && !table.attr("data-table-searching")) {
			jQuery(this).closest(".dataTables_wrapper").find(".row-fluid").remove();
		}
	}).dataTable(options);
}

function applyPopover(selector, properties) {
	properties = jQuery.extend({}, {
		html: true,
		container: "body",
		trigger: 'manual',
		placement: function (context, source) {
	        var position = jQuery(source).offset();

	        if (position.left > 515) {
	            return "left";
	        }

	        if (position.left < 515) {
	            return "right";
	        }

	        if (position.top < 110){
	            return "bottom";
	        }

	        return "top";
	    },
	    delay: {
	    	show: 200,
	    	hide: 200
	    }
	}, properties);
	
	var hidePopover = function (_this) {
		if(jQuery(_this).data("timer")) clearTimeout(jQuery(_this).data("timer"));
		jQuery(_this).data("timer", setTimeout(function() {
	        if (!jQuery(_this).hasClass("about-to-pop") && !jQuery(".popover:hover").length) {
	        	jQuery(_this).popover("hide").trigger("popover-hidden");
	        }
		}, properties.delay.hide));
    };
    
    var onMouseEnter = function () {
        var _this = this;
        jQuery(_this).addClass("about-to-pop");
        if(jQuery(_this).data("timer")) clearTimeout(jQuery(_this).data("timer"));
		//jQuery(".popover").remove(); //Hide others
        jQuery(_this).data("timer", setTimeout(function() {
	        jQuery(_this).popover("show").trigger("popover-shown");
	        jQuery(".popover").on("mouseleave", function() {
	        	hidePopover(_this); 
	        });
        }, properties.delay.show));
    }
    
    var onMouseLeave = function () {
        jQuery(this).removeClass("about-to-pop");
    	hidePopover(this);
    }

    /*if(properties.click) {
    	jQuery(selector).on("click",  function(e) {
	    	e.stopPropagation(); //FIXME: Can we avoid this?
	    	
	    	var _this = this;
	    	jQuery(selector).off("mouseenter.dna2-popover").off("mouseleave.dna2-popover");
	    	jQuery(_this).popover("show").trigger("popover-shown");

    		jQuery(document).one("click", function(ev) {
				jQuery(_this).popover("hide").trigger("popover-hidden");
			
				//Reattach
				jQuery(selector).on("mouseenter.dna2-popover", onMouseEnter).on("mouseleave.dna2-popover", onMouseLeave)
    		})
	    	
	    	jQuery(".popover").click(function(e) {
	    		e.stopPropagation();
	    	})
	    })
    
    }*/
    
	return jQuery(selector).popover(properties)
		.on("mouseenter.dna2-popover", onMouseEnter)
		.on("mouseleave.dna2-popover", onMouseLeave);
}

function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)");
    var results = regex.exec(location.search);
    return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

function dataTablesOnError(xhr, error, thrown) {
	if(!getParameterByName("reload"))
		location.href = location.href + (location.search.indexOf("?") == 0 ? "&" : "?") + "reload=true";
	jQuery(".dataTables_processing").html("<div class='alert alert-error'>Error processing</div>");
}

if(!String.prototype.trim) {
  String.prototype.trim = function () {  
    return this.replace(/^\s+|\s+$/g,'');  
  };  
} 

function doModalLogin() {
	jQuery("#loginModal").remove();
	
	var html =  '<div class="modal hide fade" id="loginModal" tabindex="-1" data-backdrop="static">' +
			'	<div class="modal-header">' +
			'		<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h3>Login</h3>' +
			'	</div>' +
			'	<div class="modal-body" style="max-height: 300px;">' +
			'		<div class="form-horizontal">' +
			'			<div class="control-group">' +
			'				<label class="control-label" for="email">Email</label>' +
			'				<div class="controls">' +
			'					<input type="text" name="email" />' +
			'				</div>' +
			'			</div>' +
			'			<div class="control-group">' +
			'				<label class="control-label" for="password">Password</label>' +
			'				<div class="controls">' +
			'					<input type="password" name="password" autocomplete="off"/>' +
			'				</div>' +
			'			</div>' +
			'<div class="error-container"></div>' +
			'			<div class="control-group">' +
			'				<div class="controls">' +
			'					<div>' +
			'						<button class="btn btn-primary btn-large" style="margin-bottom:20px;" id="loginModalSubmit">Sign In</button>' +
			'					</div>' +
			'					<div>' +
			'						<a href="/eCommerce/create" target="_blank" data-dismiss="modal">Create a new account</a>' +
			'					</div>' +
			'					<span style="text-align: right;"><a href="/eCommerce/login/forgotPassword" target="_blank" data-dismiss="modal">Forgot your password? Get password help.</a></span>' +
			'				</div>' +
			'			</div>' +
			'		</div>' +
			'	</div>' +
			'</div>';
		
	jQuery("body").append(html);
	
	jQuery("#loginModal").modal('show').on("hidden", function() {
		jQuery("#loginModal").remove();
	});
	
	jQuery("#loginModal .modal-body input").change( function(e) {
		jQuery("#loginModal .modal-body .error-container").empty();
	});
	
	jQuery("#loginModalSubmit").click( function(e) {
		jQuery("#loginModal .modal-body .error-container").empty();
		jQuery.ajax({
			type: "POST",
			url: "/eCommerce/login/auth",
			data: {
				email: jQuery("#loginModal .modal-body input[name=email]").val(),
				password: jQuery("#loginModal .modal-body input[name=password]").val()
			}
		}).done(function(reply) {
			jQuery("#loginModal").modal('hide');
			updateCart();
			jQuery(document).trigger("signedIn.dna2");
		}).fail(function() {
			jQuery("#loginModal .modal-body .error-container").empty().append('<div style="text-align: center" class="alert alert-error error dna2-error">Sorry, your sign in attempt was unsuccessful. Please try again.</div>');
		});
	})
}