#!/bin/perl -s
VERSION="0.0.2"

###############################################################################################
#####                          Direct manipulation of Mautic files                        #####
###############################################################################################
#11.09.2023
#
#https://perldoc.perl.org/perlrequick
#
#Run with: perl -s script-d10-adjusting.perl "$MAUTIC_FOLDER" "$MAUTIC_SUBDOMAIN"


use strict;
use warnings;
use POSIX qw(strftime);

#make multiline replace possible
#use also with modifiers smg
BEGIN {undef $/;}

#index; to know how many replacements were done
my $i=1;
my $OLD_CONTENT="";
my $NEW_CONTENT="";

my $MAUTIC_FOLDER = $ARGV[0];
my $MAUTIC_SUBDOMAIN = $ARGV[1];

show_info('📝', 'Active animation in multi-page forms (1)...');
$OLD_CONTENT=q{var thePage=theForm.querySelector('[data-mautic-form-page="'+showPageNumber+'"]');if(thePage){thePage.style.display='block'}};
$NEW_CONTENT=q(var thePage=theForm.querySelector('[data-mautic-form-page="'+showPageNumber+'"]');if(thePage){thePage.style.display='block';thePage.style.animation='fade_in_show 0.5s';});
replace_text($OLD_CONTENT, $NEW_CONTENT, "${MAUTIC_FOLDER}app/assets/js/mautic-form.js");
#replace_text($OLD_CONTENT, $NEW_CONTENT, "${MAUTIC_FOLDER}media/js/mautic-form.js");


show_info('📝', 'Active animation in multi-page forms (2)...');
$OLD_CONTENT=q{var showPageBreak=theForm.querySelector('[data-mautic-form-pagebreak="'+showPageNumber+'"]');if(showPageBreak){showPageBreak.style.display='block';}};
$NEW_CONTENT=q(var showPageBreak=theForm.querySelector('[data-mautic-form-pagebreak="'+showPageNumber+'"]');if(showPageBreak){showPageBreak.style.display='block';showPageBreak.style.animation='fade_in_show 0.5s';});
replace_text($OLD_CONTENT, $NEW_CONTENT, "${MAUTIC_FOLDER}app/assets/js/mautic-form.js");
#replace_text($OLD_CONTENT, $NEW_CONTENT, "${MAUTIC_FOLDER}media/js/mautic-form.js");


show_info('📝', 'Show segment informations also on smartphone...');
$OLD_CONTENT=q{.visible-xs,.visible-sm,.visible-md,.visible-lg{display:none !important}};
$NEW_CONTENT=q(/*.visible-xs,.visible-sm,.visible-md,.visible-lg{display:none !important}*/);
replace_text($OLD_CONTENT, $NEW_CONTENT, "${MAUTIC_FOLDER}app/assets/css/libraries.css");
#replace_text($OLD_CONTENT, $NEW_CONTENT, "${MAUTIC_FOLDER}media/css/libraries.css");


show_info('📝', 'Split of long lines on spaces also on smartphone...');
$OLD_CONTENT=q{.table-responsive>.table>thead>tr>th,.table-responsive>.table>tbody>tr>th,.table-responsive>.table>tfoot>tr>th,.table-responsive>.table>thead>tr>td,.table-responsive>.table>tbody>tr>td,.table-responsive>.table>tfoot>tr>td{white-space:nowrap}};
$NEW_CONTENT=q(/*.table-responsive>.table>thead>tr>th,.table-responsive>.table>tbody>tr>th,.table-responsive>.table>tfoot>tr>th,.table-responsive>.table>thead>tr>td,.table-responsive>.table>tbody>tr>td,.table-responsive>.table>tfoot>tr>td{white-space:nowrap}*/);
replace_text($OLD_CONTENT, $NEW_CONTENT, "${MAUTIC_FOLDER}app/assets/css/libraries.css");
#replace_text($OLD_CONTENT, $NEW_CONTENT, "${MAUTIC_FOLDER}media/css/libraries.css");


show_info('📝', 'Send of the campaign emails using owner timezone...');
$OLD_CONTENT=q{private function getExecutionDateTimeFromHour(Lead $contact, \DateTime $hour, $eventId, \DateTime $compareFromDateTime)
    {
        $groupHour = clone $hour;

        // Set execution to UTC
        if ($timezone = $contact->getTimezone()) {
            try {
                // Set the group's timezone to the contact's
                $contactTimezone = new \DateTimeZone($timezone);

                $this->logger->debug(
                    'CAMPAIGN: ('.$eventId.') Setting '.$timezone.' for contact '.$contact->getId()
                );

                // Get now in the contacts timezone then add the number of days from now and the original execution date
                $groupExecutionDate = clone $compareFromDateTime;
                $groupExecutionDate->setTimezone($contactTimezone);

                $groupExecutionDate->setTime($groupHour->format('H'), $groupHour->format('i'));

                return $groupExecutionDate;
            } catch (\Exception $exception) {
                // Timezone is not recognized so use the default
                $this->logger->debug(
                    'CAMPAIGN: ('.$eventId.') '.$timezone.' for contact '.$contact->getId().' is not recognized'
                );
            }
        }

        $groupExecutionDate = clone $compareFromDateTime;
        $groupExecutionDate->setTimezone($this->getDefaultTimezone());

        $groupExecutionDate->setTime($groupHour->format('H'), $groupHour->format('i'));

        return $groupExecutionDate;
    }};
$NEW_CONTENT=q(private function getExecutionDateTimeFromHour(Lead $contact, \DateTime $hour, $eventId, \DateTime $compareFromDateTime)
    {
        $groupHour = clone $hour;

        // Set execution to UTC
        if ($timezone = $contact->getTimezone()) {
            try {
                // Set the group's timezone to the contact's
/** Commented out in order to remove sending at contacts preferred timezone
                $contactTimezone = new \DateTimeZone($timezone);

                $this->logger->debug(
                    'CAMPAIGN: ('.$eventId.') Setting '.$timezone.' for contact '.$contact->getId()
                );

                // Get now in the contacts timezone then add the number of days from now and the original execution date
                $groupExecutionDate = clone $compareFromDateTime;
                $groupExecutionDate->setTimezone($contactTimezone);

                $groupExecutionDate->setTime($groupHour->format('H'), $groupHour->format('i'));

                return $groupExecutionDate;
**/
            } catch (\Exception $exception) {
                // Timezone is not recognized so use the default
                $this->logger->debug(
                    'CAMPAIGN: ('.$eventId.') '.$timezone.' for contact '.$contact->getId().' is not recognized'
                );
            }
        }

        $groupExecutionDate = clone $compareFromDateTime;
        $groupExecutionDate->setTimezone($this->getDefaultTimezone());

        $groupExecutionDate->setTime($groupHour->format('H'), $groupHour->format('i'));

        return $groupExecutionDate;
    });
replace_text($OLD_CONTENT, $NEW_CONTENT, "${MAUTIC_FOLDER}app/bundles/CampaignBundle/Executioner/Scheduler/Mode/Interval.php");

show_info('📝', 'Remove button *Update now* from Notification...');
$NEW_CONTENT="\n.mautic-update .btn-danger{display:none !important;}";
append_text($NEW_CONTENT, "${MAUTIC_FOLDER}app/assets/css/app.css");
#append_text($NEW_CONTENT, "${MAUTIC_FOLDER}media/css/app.css");

show_info('📝', 'Correct Mautic auto log out each 10 minutes...');
$NEW_CONTENT="\njQuery(function () {setInterval(function(){jQuery.ajax({method: 'GET',url: 'https://${MAUTIC_SUBDOMAIN}/s/credentials'});}, 360000);/*every 9 minutes*/});";
append_text($NEW_CONTENT, "${MAUTIC_FOLDER}app/assets/js/app.js");
#append_text($NEW_CONTENT, "${MAUTIC_FOLDER}media/js/app.js");

show_info('📝', 'Allow attribute mautic:disable-tracking in Dynamic Content...');
#https://github.com/mautic/mautic/pull/12378
$OLD_CONTENT=q{htmlAllowedTags: ['a', 'abbr', 'address', 'area', 'article', 'aside', 'audio', 'b', 'base', 'bdi', 'bdo', 'blockquote', 'br', 'button', 'canvas', 'caption', 'cite', 'code', 'col', 'colgroup', 'datalist', 'dd', 'del', 'details', 'dfn', 'dialog', 'div', 'dl', 'dt', 'em', 'embed', 'fieldset', 'figcaption', 'figure', 'footer', 'form', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'header', 'hgroup', 'hr', 'i', 'iframe', 'img', 'input', 'ins', 'kbd', 'keygen', 'label', 'legend', 'li', 'link', 'main', 'map', 'mark', 'menu', 'menuitem', 'meter', 'nav', 'noscript', 'object', 'ol', 'optgroup', 'option', 'output', 'p', 'param', 'pre', 'progress', 'queue', 'rp', 'rt', 'ruby', 's', 'samp', 'script', 'style', 'section', 'select', 'small', 'source', 'span', 'strike', 'strong', 'sub', 'summary', 'sup', 'table', 'tbody', 'td', 'textarea', 'tfoot', 'th', 'thead', 'time', 'tr', 'track', 'u', 'ul', 'var', 'video', 'wbr'],
    htmlRemoveTags: ['script', 'style'],
    htmlAllowedAttrs: ['accept', 'accept-charset', 'accesskey', 'action', 'align', 'allowfullscreen', 'allowtransparency', 'alt', 'async', 'autocomplete', 'autofocus', 'autoplay', 'autosave', 'background', 'bgcolor', 'border', 'charset', 'cellpadding', 'cellspacing', 'checked', 'cite', 'class', 'color', 'cols', 'colspan', 'content', 'contenteditable', 'contextmenu', 'controls', 'coords', 'data', 'data-.*', 'datetime', 'default', 'defer', 'dir', 'dirname', 'disabled', 'download', 'draggable', 'dropzone', 'enctype', 'for', 'form', 'formaction', 'frameborder', 'headers', 'height', 'hidden', 'high', 'href', 'hreflang', 'http-equiv', 'icon', 'id', 'ismap', 'itemprop', 'keytype', 'kind', 'label', 'lang', 'language', 'list', 'loop', 'low', 'max', 'maxlength', 'media', 'method', 'min', 'mozallowfullscreen', 'multiple', 'name', 'novalidate', 'open', 'optimum', 'pattern', 'ping', 'placeholder', 'poster', 'preload', 'pubdate', 'radiogroup', 'readonly', 'rel', 'required', 'reversed', 'rows', 'rowspan', 'sandbox', 'scope', 'scoped', 'scrolling', 'seamless', 'selected', 'shape', 'size', 'sizes', 'span', 'src', 'srcdoc', 'srclang', 'srcset', 'start', 'step', 'summary', 'spellcheck', 'style', 'tabindex', 'target', 'title', 'type', 'translate', 'usemap', 'value', 'valign', 'webkitallowfullscreen', 'width', 'wrap'],
    htmlAllowComments: true,
    htmlUntouched: false,
    fullPage: false // Will also turn iframe on.};
$NEW_CONTENT=q(htmlAllowedTags: ['a', 'abbr', 'address', 'area', 'article', 'aside', 'audio', 'b', 'base', 'bdi', 'bdo', 'blockquote', 'br', 'button', 'canvas', 'caption', 'cite', 'code', 'col', 'colgroup', 'datalist', 'dd', 'del', 'details', 'dfn', 'dialog', 'div', 'dl', 'dt', 'em', 'embed', 'fieldset', 'figcaption', 'figure', 'footer', 'form', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'header', 'hgroup', 'hr', 'i', 'iframe', 'img', 'input', 'ins', 'kbd', 'keygen', 'label', 'legend', 'li', 'link', 'main', 'map', 'mark', 'menu', 'menuitem', 'meter', 'nav', 'noscript', 'object', 'ol', 'optgroup', 'option', 'output', 'p', 'param', 'pre', 'progress', 'queue', 'rp', 'rt', 'ruby', 's', 'samp', 'script', 'style', 'section', 'select', 'small', 'source', 'span', 'strike', 'strong', 'sub', 'summary', 'sup', 'table', 'tbody', 'td', 'textarea', 'tfoot', 'th', 'thead', 'time', 'tr', 'track', 'u', 'ul', 'var', 'video', 'wbr', 'center'],
    htmlRemoveTags: [],
    htmlAllowedAttrs: ['accept', 'accept-charset', 'accesskey', 'action', 'align', 'allowfullscreen', 'allowtransparency', 'alt', 'async', 'autocomplete', 'autofocus', 'autoplay', 'autosave', 'background', 'bgcolor', 'border', 'charset', 'cellpadding', 'cellspacing', 'checked', 'cite', 'class', 'color', 'cols', 'colspan', 'content', 'contenteditable', 'contextmenu', 'controls', 'coords', 'data', 'data-.*', 'datetime', 'default', 'defer', 'dir', 'dirname', 'disabled', 'download', 'draggable', 'dropzone', 'enctype', 'for', 'form', 'formaction', 'frameborder', 'headers', 'height', 'hidden', 'high', 'href', 'hreflang', 'http-equiv', 'icon', 'id', 'ismap', 'itemprop', 'keytype', 'kind', 'label', 'lang', 'language', 'list', 'loop', 'low', 'max', 'maxlength', 'media', 'method', 'min', 'mozallowfullscreen', 'multiple', 'name', 'novalidate', 'open', 'optimum', 'pattern', 'ping', 'placeholder', 'poster', 'preload', 'pubdate', 'radiogroup', 'readonly', 'rel', 'required', 'reversed', 'rows', 'rowspan', 'sandbox', 'scope', 'scoped', 'scrolling', 'seamless', 'selected', 'shape', 'size', 'sizes', 'span', 'src', 'srcdoc', 'srclang', 'srcset', 'start', 'step', 'summary', 'spellcheck', 'style', 'tabindex', 'target', 'title', 'type', 'translate', 'usemap', 'value', 'valign', 'webkitallowfullscreen', 'width', 'wrap', 'mautic:disable-tracking'],
    htmlAllowComments: true,
    htmlUntouched: false,
    fullPage: false // Will also turn iframe on.);
replace_text($OLD_CONTENT, $NEW_CONTENT, "${MAUTIC_FOLDER}app/bundles/CoreBundle/Assets/js/libraries/froala/froala_editor.js");

show_info('📝', 'Fix the dynamic content events are not displayed on the lead timeline...');
#https://github.com/mautic/mautic/pull/11726
$OLD_CONTENT=q{$eventTypeNameSent = $this->translator->trans('mautic.dynamic.content.sent');};
$NEW_CONTENT=q($eventTypeNameSent = $this->translator->trans('mautic.dynamic.content.triggered'););
replace_text($OLD_CONTENT, $NEW_CONTENT, "${MAUTIC_FOLDER}app/bundles/DynamicContentBundle/EventListener/LeadSubscriber.php");

$OLD_CONTENT=q{'icon'            => 'fa-envelope',};
$NEW_CONTENT=q('icon'            => 'fa-puzzle-piece',);
replace_text($OLD_CONTENT, $NEW_CONTENT, "${MAUTIC_FOLDER}app/bundles/DynamicContentBundle/EventListener/LeadSubscriber.php");

$OLD_CONTENT=q{mautic.dynamic.content.sent="Dynamic Content Sent"};
$NEW_CONTENT=q(mautic.dynamic.content.triggered="Dynamic Content Triggered");
replace_text($OLD_CONTENT, $NEW_CONTENT, "${MAUTIC_FOLDER}app/bundles/DynamicContentBundle/Translations/en_US/messages.ini");

$OLD_CONTENT=q{$data = $event['extra']['log']['metadata'];};
$NEW_CONTENT=q($data = $event['extra']['stat']['sentDetails'];);
replace_text($OLD_CONTENT, $NEW_CONTENT, "${MAUTIC_FOLDER}app/bundles/DynamicContentBundle/Views/SubscribedEvents/Timeline/index.html.php");

show_info('📝', 'Fix: Letters disappear when searching for emails to send in Campaign Builder...');
#https://github.com/mautic/mautic/pull/14032
$OLD_CONTENT=q{$.each(items, function (i, element) {
                        var group, text, value;
                        nbItems++;
                        if (element.group) {
                            group = select.find("optgroup[label='" + element.text + "']");
                            if (!group.length) {
                                group = $("<optgroup />");
                            }
                            group.attr('label', element.text).appendTo(select);
                            return $.each(element.items, function (i, element) {
                                var text, value;
                                if (typeof element === "string") {
                                    value = i;
                                    text = element;
                                } else {
                                    value = element.value;
                                    text = element.text;
                                }
                                if ($.inArray(value + "-" + text, selected_values) === -1) {
                                    return $("<option />").attr('value', value).html(text).appendTo(group);
                                }
                            });
                        } else {
                            if (typeof element === "string") {
                                value = i;
                                text = element;
                            } else {
                                value = element.value;
                                text = element.text;
                            }
                            if ($.inArray(value + "-" + text, selected_values) === -1) {
                                return $("<option />").attr('value', value).html(text).appendTo(select);
                            }
                        }
                    });
                    if (nbItems) {
                        // Re-append new back to the top
                        if (hasNew) {
                            hasNew.prependTo(select);
                        }
                        select.trigger("chosen:updated");

                        setTimeout( function() {
                            // Hack to force chosen to hide already selected values from the list
                            var e = $.Event("keyup.chosen");
                            e.which = 93; // Windows/Command
                            field.trigger(e);
                        }, 5);
                    } else {
                        select.data().chosen.no_results_clear();
                        select.data().chosen.no_results(field.val());
                    }
                    if (settings.success != null) {
                        settings.success(data);
                    }
                    var returnVar = field.val(untrimmed_val);};
$NEW_CONTENT=q(var searchValue = field.val();
                    $.each(items, function (i, element) {
                        var group, text, value;
                        nbItems++;
                        if (element.group) {
                            group = select.find("optgroup[label='" + element.text + "']");
                            if (!group.length) {
                                group = $("<optgroup />");
                            }
                            group.attr('label', element.text).appendTo(select);
                            return $.each(element.items, function (i, element) {
                                var text, value;
                                if (typeof element === "string") {
                                    value = i;
                                    text = element;
                                } else {
                                    value = element.value;
                                    text = element.text;
                                }
                                if ($.inArray(value + "-" + text, selected_values) === -1) {
                                    return $("<option />").attr('value', value).html(text).appendTo(group);
                                }
                            });
                        } else {
                            if (typeof element === "string") {
                                value = i;
                                text = element;
                            } else {
                                value = element.value;
                                text = element.text;
                            }
                            if ($.inArray(value + "-" + text, selected_values) === -1) {
                                return $("<option />").attr('value', value).html(text).appendTo(select);
                            }
                        }
                    });
                    if (nbItems) {
                        // Re-append new back to the top
                        if (hasNew) {
                            hasNew.prependTo(select);
                        }
                        select.trigger("chosen:updated");

                        setTimeout( function() {
                            // Hack to force chosen to hide already selected values from the list
                            var e = $.Event("keyup.chosen");
                            e.which = 93; // Windows/Command
                            field.trigger(e);
                        }, 5);
                    } else {
                        select.data().chosen.no_results_clear();
                        select.data().chosen.no_results(field.val());
                    }
                    if (settings.success != null) {
                        settings.success(data);
                    }
                    var returnVar = field.val(searchValue););
replace_text($OLD_CONTENT, $NEW_CONTENT, "${MAUTIC_FOLDER}app/bundles/CoreBundle/Assets/js/libraries/3b.chosen.ajax.js");


show_info('✅', 'Success => now clear the cache and regenerate assets to see the result.');
exit;

sub append_text {
	my ($append_text_this, $append_text_filename) = @_;
	
	open(my $fh, '>>', $append_text_filename) or die "Could not open file '$append_text_filename' $!";
	say $fh $append_text_this;
	close $fh;
	print $i++, " ";
	return;
}

sub replace_bigtext {
  my ($replace_text_start, $replace_text_end, $replace_text_new, $replace_text_filename) = @_;
	
	my $replace_text_old_q=$replace_text_start;
	$replace_text_old_q=$replace_text_old_q . '(.*?)';
	$replace_text_old_q=$replace_text_old_q . $replace_text_end;
	
	my $data = read_file($replace_text_filename);
	$data =~ s/$replace_text_old_q/$replace_text_new/smg;
	write_file($replace_text_filename, $data);
	print $i++, " ";
	return;
}

sub replace_text {
  my ($replace_text_old, $replace_text_new, $replace_text_filename) = @_;

	my $replace_text_old_q=quotemeta $replace_text_old;
	my $data = read_file($replace_text_filename);
	$data =~ s/$replace_text_old_q/$replace_text_new/smg;
	write_file($replace_text_filename, $data);
	print $i++, " ";
	return;
}

sub read_file {
  my ($filename) = @_;

  open my $in, '<:encoding(UTF-8)', $filename or die "Could not open '$filename' for reading $!";
  local $/ = undef;
  my $all = <$in>;
  close $in;

  return $all;
}

sub write_file {
  my ($filename, $content) = @_;

  open my $out, '>:encoding(UTF-8)', $filename or die "Could not open '$filename' for writing $!";;
  print $out $content;
  close $out;

  return;
}

sub show_info {
  my ($state, $comment) = @_;
  my $timestamp = strftime("%Y-%m-%d_%H:%M:%S", localtime);
  print "\n[$timestamp]  InstallScript  $state  $comment";
}
