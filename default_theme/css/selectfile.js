$(function () {
    $('#themes').change(function () {
        changeTheme($(':selected').val());
    });
});

function changeTheme(theme) {
    var stylshit = $('[title="hakyll_theme"]');
        stylshit.attr('href','/css/'+theme.toLowerCase()+'.css');
}
