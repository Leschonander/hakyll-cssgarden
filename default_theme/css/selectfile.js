$(function () {
  var query = location.search.substr(1);
  var s = "";
  var tValue = "default";
  query.split("&").forEach(function(part) {
        var item = part.split("=");
        s += " " + item;
        if (item[0] == "theme"){
          tValue = item[1];
        }
  });
  
  changeTheme(tValue);
  updateLinks(tValue);
  $('.styleInfo').html("Currently viewing <a href='/css/" + tValue + ".css'>" + tValue + "</a> ; " + s);
  

  $('#themes').change(function () {
      var item = $(':selected').val();
      window.location= location.search.split('?')[0] +'?theme=' + item;
  });
});

function changeTheme(theme) {
    var stylshit = $('[title="hakyll_theme"]');
        stylshit.attr('href','./css/'+theme.toLowerCase()+'.css');
}

function updateLinks(theme) {
  $.each(
    $('#navigation a'), function(index, value) {
      $(value).attr('href', $(value).attr('href') + '?theme=' + theme);
    }
  );
}
