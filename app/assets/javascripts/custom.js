alert(2);

$(function() {

    $('.main-block-content').css('min-height', $(window).height()-70);

    $('.post-tags-editor').tagEditor({
         autocomplete: {
             source: '/tags/for-post',
             minLength: 2,
             delay: 0,
             position: { collision: 'flip' }
         }
     });

     $('.post-tags-filter').tagEditor({
         autocomplete: {
             source: '/tags/for-post',
             minLength: 2,
             delay: 0,
             position: { collision: 'flip' }
         }
     });

     $('.tags-post-filter').tagEditor({
         autocomplete: {
             source: '/posts/autocomplete',
             minLength: 2,
             delay: 0,
             position: { collision: 'flip' }
         }
     });

     $('.tags-photos-filter').tagEditor({
         autocomplete: {
             source: '/photos/autocomplete',
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


    if ($('#photo-content').length) {
        $('#photo-content').updatePostTable({
            url: '/photos/filter/'
        });
    } else {
        $('#table-content').updatePostTable({
            url: '/posts/filter/'
        });
        $('#tags-content').updatePostTable({
            url: '/tags/filter/'
        });
    }


    $('.list-file-upload, #photo-content').on( 'click', '.photo-edit', function(e) {
        var $this = $(this);
        e.preventDefault();
        $.ajax({
            url: $this.prop('href'),
            type: 'GET',
            dataType : 'html',
            success: function( html ) {
                var title = 'Photo';
                var globalPopup = {
                    wrapper :   $('.bs-example-modal-lg'),
                    title :     '.modal-title',
                    content :   '.modal-content'
                };
                globalPopup.wrapper.addClass('bs-photo-lg');
                globalPopup.wrapper.find(globalPopup.content).empty().html(html);
                globalPopup.wrapper.find(globalPopup.title).empty().html(title);
                globalPopup.wrapper.modal({
                    keyboard : true,
                    backdrop : 'static'
                });
            },
            error: function( xhr, status, errorThrown ) {
                alert( "Sorry, there was a problem!" );
                console.log( "Error: " + errorThrown );
                console.log( "Status: " + status );
                console.dir( xhr );
            }
        });

    });

    $('.btn-show-photos-ajax').click(function(e){
        e.preventDefault();
        $('.toggle-filter').toggle();
    });

    $('.to-toggle-filter').click(function(){
        $('.toggle-filter').toggle();
    });

    $('.show-view-type').click(function(){
        var showType = $(this).data('type');
        $('.show-view-type').toggleClass('active');
        $('.thumbnail-list').removeClass('thumbnail-list-grid').removeClass('thumbnail-list-list').addClass('thumbnail-list-'+showType);
    });

});


(function( $ ) {

    $.fn.updatePostTable = function(opts) {

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
            fotoramaClass : 'fotorama',
            orderType : $('.show-order-type')
        }, opts);

        var $form = $('#'+config.formId);

        // main function
        function updatePostTable(){

            var $inputs = $('input, textarea, select', $form);

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

            if (config.orderType.length) {
                values['photo_order_type'] = config.orderType.filter('.active').data('type')
            }
            console.log(values);

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

        config.orderType.click(function(e){
            e.preventDefault();
            config.orderType.removeClass('active');
            $(this).addClass('active');
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

            });
        return this;
    };

}( jQuery ));