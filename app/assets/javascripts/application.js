// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require tinymce
//= require bootstrap-datepicker
//= require jquery-fileupload
//= require_tree .
$(document).ready(function(){
    $('.post-tags-editor').tagEditor({
        autocomplete: { 'source': '/tags/forpost', minLength: 2, delay: 0, position: { collision: 'flip' } }
    });

    $('.datepicker').datepicker({
        format: 'dd/mm/yyyy'
    });


    $('.btn-show-photos').click(function(){
        $('.bs-example-modal-lg').modal({
            keyboard : true,
            backdrop : 'static'
        })
    });

});