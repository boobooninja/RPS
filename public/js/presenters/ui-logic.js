(function() {

  var PresentationUI = function() {


    // $(document).on("click", "#add-new-joke-submit", function(){
    //   var joke = $('#new-joke-input').val()
    //     , answer = $('#new-joke-answer-input').val()
    //     , newId = jokes.length + 1
    //   ;
    //   bl.addJokeToLocalJokes(newId, joke, answer);
    // });

    $(document).on('click', '.employee-listing', function() {
      var id = $(this).find('.id').val();
      // render employee view
      console.log("Employee ID: " + id);
    });

    $(document).on('hover', '.employee-listing', function() {
      $(this).css('cursor', 'pointer');
    });


  };

  // this runs it
  window.presentationUI = new PresentationUI();

})();
