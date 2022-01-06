(function($) {

 function init() {
    /* Sidebar height set */
    $sidebarStyles = $('.sidebar').attr('style') || "";
    $sidebarStyles += ' min-height: ' + $(document).height() + 'px;';
    $('.sidebar').attr('style', $sidebarStyles);

    /* Secondary contact links */
    var $scontacts = $('#contact-list-secondary');
    var $contactList = $('#contact-list');

    $scontacts.hide();
    $contactList.mouseenter(function(){ $scontacts.fadeIn(); });
    $contactList.mouseleave(function(){ $scontacts.fadeOut(); });

    /**
     * Tags & categories tab activation based on hash value. If hash is undefined then first tab is activated.
     */
    function activateTab() {
      if(['/tags.html', '/categories.html'].indexOf(window.location.pathname) > -1) {
        var hash = window.location.hash;
        if(hash)
          $('.tab-pane').length && $('a[href="' + hash + '"]').tab('show');
        else
          $('.tab-pane').length && $($('.cat-tag-menu li a')[0]).tab('show');
      }
    }

    // watch hash change and activate relevant tab
    $(window).on('hashchange', activateTab);

    // initial activation
    activateTab();

    // sidebar-sm init
    $("#sidebar-expand-menu").hide();

    if (document.getElementById("projects-pills-tab") != null) {
      setActive(null);
    }
  };

  // run init on document ready
  $(document).ready(init);

})(jQuery);

function sidebarExpandBtn() {
  var sidebar = $("#sidebar-expand-menu");
  if (sidebar.is(':hidden'))
    sidebar.show();
  else
    sidebar.hide();
}
function updateCarouselModal(carouselElement) {
  console.log(`updating for ${carouselElement}`);
  var carousel = document.getElementById(`${carouselElement}Indicators`);
  var modalTitle = document.getElementById(`${carouselElement}fullScreenModalTitle`);
  var modalImg = document.getElementById(`${carouselElement}fullScreenModalImg`);
  var carouselItems = carousel.getElementsByClassName("carousel-item");
  // Iterate through carouselItems and find active in classList

  for (var i = 0; i < carouselItems.length; i++) {
    var item = carouselItems[i];

    if (item.classList.contains("active")) {
      var imgElement = item.getElementsByTagName("img")[0];
      var captionElement = item.getElementsByTagName("h5")[0];
      console.log(imgElement);
      console.log(captionElement);
      modalImg.setAttribute("src", imgElement.getAttribute("src"));
      console.log(`Image Element text: ${imgElement.textContent}`);
      modalTitle.textContent = captionElement.textContent;
    }
  }
}
function setActive(newActive) {
  var projectsTab = document.getElementById("projects-pills-tab");
  
  if (newActive == null) {
    // Check if there's an active tab in the URL
    // If so, update the tab view
    var found = false;
    if (window.location.hash !== "") {
      var active = window.location.hash.split("#")[1];

      for (var i = 0; i < projectsTab.children.length; i++) {
        var tab = projectsTab.children[i];
        var tabBtn = tab.children[0];

        if (tabBtn.id.includes(active)) {
          tabBtn.click();
          found = true;
          break;
        }
      }

      if (!found) {
        window.location.hash = "";
      }
    }
  }
  else {
    // Set the active tab in the URL
    window.location.hash = `#${newActive}`;
  }
}