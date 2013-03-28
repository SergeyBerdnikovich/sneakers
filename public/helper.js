function PlaySound(soundobj) {
    var thissound=document.getElementById(soundobj);
    thissound.play();
}

function StopSound(soundobj) {
    var thissound=document.getElementById(soundobj);
    thissound.pause();
    thissound.currentTime = 0;
}
window.onbeforeunload = "Are you sure you want to leave? RSVP could be missed!";


window.onbeforeunload = function(e) {
    return "Are you sure you want to leave? RSVP could be missed!";
};


var flashint = null;
var soundint = nulll
function startRSVP(image,id){
     
self.focus();
text = '<center><img onClick="$(\'#txt\').focus();" style="max-width: 100%;height: 70%;width: auto \9;" src="'+image+'"></img><p>';
text += '<b>Please enter keyword</b> <input id="txt" onkeydown="StopSound(\'mySound\');clearInterval(soundint);" type=text size=10>'
text += '<input type=button onclick="stopRSVP()" value="Send keyword">'
$('#workarea').html(text);
PlaySound('mySound');
$('#txt').focus();
soundint = setInterval("PlaySound('mySound');", 3000);
flashint = setInterval("flashTitle('___NEW RSVP___', '===NEW RSVP===')", 800);
alert("RSVP!!!!!!!!!!!!!!!!!!!!!!!!!!")
$('#txt').keypress(function(e) {
    if(e.which == 13) {
        stopRSVP()
    }
});

}




function stopRSVP(){

    clearInterval(flashint);
    
    clearInterval(soundint);
    document.title == "";
    StopSound('mySound');
    $('#workarea').html("");

}

function flashTitle(pageTitle, newMessageTitle)
{
    if (document.title == pageTitle)
    {
        document.title = newMessageTitle;
    }
    else
    {
        document.title = pageTitle;
    }
}
