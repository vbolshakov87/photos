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
$(function() {
    $('.post-tags-editor').tagEditor({
        autocomplete: {
            source: '/tags/for-post',
            minLength: 2,
            delay: 0,
            position: { collision: 'flip' } }
    });

    $('.post-tags-filter').tagEditor({
        autocomplete: {
            source: '/tags/for-post',
            minLength: 2,
            delay: 0,
            position: { collision: 'flip' }
        }
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

    $('#table-content').updatePostTable();

    $('.btn-show-photos-ajax').click(function(e){
        e.preventDefault();
        $('.toggle-filter').toggle();
    });

    $('.to-toggle-filter').click(function(){
        $('.toggle-filter').toggle();
    });

});


(function( $ ) {

    $.fn.updatePostTable = function(opts) {

        // default configuration
        var config = $.extend({}, {
            url: '/posts/filter/',
            formId: 'post-filter-form',
            changeSort: '.change-sort',
            wrapper: $(this),
            pagination :'.pagination:first',
            perPage :'.btn-group-per-page:first .dropdown-menu li',
            perPageWrapper :'.btn-group-per-page:first',
            btnShowPhotosAjax :'.btn-show-photos-ajax',
            popup : {
                wrapper :   $('.bs-example-modal-lg'),
                title :     '.modal-title',
                content :   '.modal-content'
            },
            fotoramaClass : 'fotorama'
        }, opts);

        var $form = $('#'+config.formId);

        // main function
        function updatePostTable(){
            var $inputs = $('input', $form);

            var values = {};
            // filter
            $inputs.each(function() {
                values[this.name] = $(this).val();
            });

            // sort
            var sort = {};
            $(config.changeSort).each(function(){
               var $this = $(this);
               if (($this.data('direction') != 'empty' && $this.data('to-change') === undefined) || ($this.data('to-change') != undefined && $this.data('new-direction') != 'empty')) {
                    sort[$this.data('by')] =
                        $this.data('to-change') != undefined ?
                            $this.data('new-direction') :
                            $this.data('direction');
                }
            });
            values['sort'] = sort;

            // pager
            values['page'] = 1;
            $(config.pagination + ' a').each(function(){
                var $this = $(this);
                if ($this.data('active-page') !== undefined) {
                    values['page'] = $this.data('active-page');
                    return false;
                }
            });

            values['per_page'] = $(config.perPageWrapper).data('per-page');

            $.ajax({
                url: config.url,
                data: values,
                type: 'GET',
                dataType : 'html',
                success: function( html ) {
                    config.wrapper.empty().html(html);
                },
                error: function( xhr, status, errorThrown ) {
                    alert( "Sorry, there was a problem!" );
                    console.log( "Error: " + errorThrown );
                    console.log( "Status: " + status );
                    console.dir( xhr );
                }
            });
        }

        $form.submit(function(e){
            e.preventDefault();
            updatePostTable();
        });

        config.wrapper
            .on( 'click', config.changeSort, function(e) {
                e.preventDefault();
                $(this).data('to-change', true);
                updatePostTable();
        })
            .on( 'click', config.pagination + ' a', function(e) {
                e.preventDefault();
                $(this).data('active-page', $(this).text());
                updatePostTable();
            })
            .on( 'click', config.perPage + ' a', function(e) {
                e.preventDefault();
                $(config.perPageWrapper).data('per-page', $(this).text());
                updatePostTable();
            })
            .on( 'click', config.btnShowPhotosAjax, function(e) {
                var $this = $(this);
                e.preventDefault();
                $.ajax({
                    url: $(this).prop('href'),
                    type: 'GET',
                    dataType : 'html',
                    success: function( html ) {
                        var title = 'Photos for ' + $this.closest('tr').find('td:eq(1)').text();
                        config.popup.wrapper.find(config.popup.content).empty().html(html);
                        config.popup.wrapper.find(config.popup.title).empty().html(title);
                        config.popup.wrapper.modal({
                            keyboard : true,
                            backdrop : 'static'
                        }).on('shown.bs.modal', function () {
                            $('.'+config.fotoramaClass).fotorama();
                        });
                    },
                    error: function( xhr, status, errorThrown ) {
                        alert( "Sorry, there was a problem!" );
                        console.log( "Error: " + errorThrown );
                        console.log( "Status: " + status );
                        console.dir( xhr );
                    }
                });

            })
        ;


        return this;

    };

}( jQuery ));

