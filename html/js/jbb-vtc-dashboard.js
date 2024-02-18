 // browser side
const elDashboard = document.getElementById('jbb-vtc-dashboard');
const elCourses = document.getElementById('jbb-vtc-dashboard-courses');
const elCurrent = document.getElementById('jbb-vtc-dashboard-current');
const elTpl = document.getElementById('jbb-vct-course-tpl');
const elAskDriver = document.getElementById('jbb-vtc-askdriver')
const elAskDriverForm = document.getElementById('jbb-vtc-askdriver-form')
const elAskDriverWaiting = document.getElementById('jbb-vtc-askdriver-waiting')
const elAskDriverComing = document.getElementById('jbb-vtc-askdriver-coming')
const elAskDriverComingName = document.getElementById('jbb-vtc-askdriver-drivername')
const elAskDriverComingPlate = document.getElementById('jbb-vtc-askdriver-driverplate')
const elAskDriverComingStatus = document.getElementById('jbb-vtc-askdriver-status')
const elAskDriverLocation = document.getElementById('jbb-vtc-askdriver-location')
const elAskDriverDistance = document.getElementById('jbb-vtc-askdriver-distance')
const elAskDriverPrice = document.getElementById('jbb-vtc-askdriver-price')
const elAskDriverPassengers = document.getElementById('jbb-vtc-askdriver-passengers')
const elAskDriverButtons = document.getElementById('jbb-vtc-askdriver-btns')
const elClientInfos = document.getElementById('jbb-vtc-client-infos')
const elClientMugshot = document.getElementById('jbb-vtc-client-mugshot')
const elClientDetailsTxt = document.getElementById('jbb-client-details-txt')
const elInputSwitchMode = document.getElementById('jbb-vtc-switchMode-input')

const driverStatus = {coming:"Your driver is on his way", here:"Your driver is here", inprogress:"Ride is in progress", finished:"You have arrived"}
var askcourse = null
var driverMode = false

function sendEvent(event, data, cb){
    fetch(`https://${GetParentResourceName()}/${event}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
    }).then(resp => {
        return resp.json()
    }).then(json => {
        if(cb)
            cb(json)
    });
}

function show(show, element){
    if(show==false) element.classList.add("hide")
    else element.classList.remove("hide")
}

function getRandom(min, max) {
    return Math.random() * (max - min) + min;
}

function getRandomInt(min, max) {
    const minCeiled = Math.ceil(min);
    const maxFloored = Math.floor(max);
    return Math.floor(Math.random() * (maxFloored - minCeiled + 1) + minCeiled);
}

function addNewCourse(values){
    var clone = elTpl.content.cloneNode(true);
    clone.getElementById("jbb-vtc-pcount").innerText = values.pcount;
    clone.getElementById("jbb-vtc-reward").innerText = values.reward;
    clone.getElementById("jbb-vtc-distance").innerText = values.distance.toFixed(1);
    clone.getElementById("jbb-vtc-pickup-distance").innerText = values.pickDistance.toFixed(1);
    clone.getElementById("jbb-vtc-pickup").innerText = values.pickup;
    clone.getElementById("jbb-vtc-destination").innerText = values.destination;
    var elCourse = clone.querySelectorAll(".jbb-vtc-course-small")[0]
    elCourse.setAttribute('id', "jbb-vtc-course-"+values.id)
    if(values.player != null){
        elCourse.classList.add("blue-grey", "darken-2", "white-text")
    }
    else{
        elCourse.classList.add("grey", "lighten-5")
    }


    var el = clone.querySelectorAll(".jbb-vtc-accept")[0]
    el.setAttribute('data-courseid', values.id)
    el.parentNode.setAttribute('id', "jbb-vtc-accept-btn-"+values.id)
    clone.querySelectorAll(".jbb-vtc-loader-item")[0].setAttribute('id', "jbb-vtc-loader-"+values.id)


    elCourses.appendChild(clone)
}

function startCourse(values){
    document.getElementById("jbb-vtc-cur-pcount").innerText = values.pcount;
    document.getElementById("jbb-vtc-cur-reward").innerText = values.reward;
    document.getElementById("jbb-vtc-cur-distance").innerText = values.distance.toFixed(1);
    document.getElementById("jbb-vtc-cur-pickup-distance").innerText = values.pickDistance.toFixed(1);
    document.getElementById("jbb-vtc-cur-pickup").innerText = values.pickup;
    document.getElementById("jbb-vtc-cur-destination").innerText = values.destination;
    document.getElementById("jbb-vtc-cur-satisfaction").setAttribute('style',"width:100%;");
    document.getElementById("jbb-vtc-cur-satisfaction-icon").innerText = "sentiment_very_satisfied";
}

function updatePlayerRate(rate){
    document.getElementById("jbb-vtc-rate").innerText = rate.toFixed(1);
    document.getElementById("jbb-vtc-cur-rate").innerText = rate.toFixed(1);
}

function updateSatisfaction(sat){
    sat = sat.toFixed(1)
    var satIcon = "sentiment_very_satisfied"
    document.getElementById("jbb-vtc-cur-satisfaction").style.width = sat+"%";
    if(sat<=20){
        satIcon = "sentiment_very_dissatisfied"
    }
    else if(sat<=50){
        satIcon = "sentiment_dissatisfied"
    }
    else if(sat<=60){
        satIcon = "sentiment_neutral"
    }
    else if(sat<=80){
        satIcon = "sentiment_satisfied"
    }
    document.getElementById("jbb-vtc-cur-satisfaction-icon").innerText = satIcon;
}

function updateDistances(courses){
    courses.forEach(course => {
        var cid = course.id
        var distance = course.pickDistance.toFixed(1)
        var elCourse = document.getElementById("jbb-vtc-course-"+cid)

        if(elCourse){
            elDist = elCourse.querySelector("#jbb-vtc-pickup-distance");
            if(elDist) elDist.innerText = distance;
        }
    })
}

function acceptCourse(courseId){
    document.getElementById("jbb-vtc-accept-btn-"+courseId).classList.add('hide')
    document.getElementById("jbb-vtc-loader-"+courseId).classList.remove('hide')
    //send NUI callback
    sendEvent("jbb:vtc:client:ui:accept",{cid: courseId}, function(data){
        if(data.success == false){
            document.getElementById("jbb-vtc-accept-btn-"+courseId).classList.remove('hide')
            document.getElementById("jbb-vtc-loader-"+courseId).classList.add('hide')
        }
    });
}

function deleteCourse(courseId){
    var toDel = document.getElementById("jbb-vtc-course-"+courseId)
    if(toDel){
        toDel.parentNode.removeChild(toDel)
    }
}

function hide(){
    sendEvent("jbb:vtc:client:ui:hide",{hide: true})
    show(false, elDashboard)
}

function resetAskForm(){
    if(driverMode == false){
        show(true, elAskDriver)
        show(false, elAskDriverForm)
        show(true, elAskDriverButtons)
        show(false, elAskDriverWaiting)
        show(false, elAskDriverComing)
        elAskDriverPassengers.disabled = false
        elAskDriverPassengers.value = "1"
        askcourse = null
    }
}

function displayAskForm(){
    show(true, elAskDriverForm)
    elAskDriverLocation.innerText = askcourse.location,
    elAskDriverDistance.innerText = (askcourse.distance/1000).toFixed(1)
    elAskDriverPrice.innerText = askcourse.price
}

function validateAsk(){
    askcourse.passengers = parseInt(elAskDriverPassengers.value)
    sendEvent("jbb:vtc:client:ui:askcourse", askcourse, function(data){
        if(data.success==true){
            show(false, elAskDriverButtons)
            show(true, elAskDriverWaiting)
            show(false, elAskDriver)
            elAskDriverPassengers.disabled = true
        }
        else{
            resetAskForm()
        }
    })
}

function cancelAsk(){
    show(false, elAskDriverForm)
    show(true, elAskDriver)
}

function askForDriver(){
    sendEvent("jbb:vtc:client:ui:askcoords",{}, function(data){
        if(data.success == true){
            askcourse = data
            displayAskForm()
        }
    })
}

function driverFound(driver){
    show(false, elAskDriverForm)
    show(false, elAskDriverWaiting)

    elAskDriverComingStatus.innerHTML = driverStatus.coming
    elAskDriverComingName.innerHTML = driver.name
    elAskDriverComingPlate.innerHTML = driver.plate
    show(true, elAskDriverComing)
}

function driverArrived(){
    statusFinished()
}

function blinkView(){
    elDashboard.classList.add("blink")
    setTimeout(function(){elDashboard.classList.remove("blink")}, 3000)
}

function statusNear(){
    elAskDriverComingStatus.innerHTML = driverStatus.here
    blinkView()
}

function statusInProgress(){
    elAskDriverComingStatus.innerHTML = driverStatus.inprogress
}

function statusFinished(){
    elAskDriverComingStatus.innerHTML = driverStatus.finished
    blinkView()
}

function cancelCourse(){
    sendEvent("jbb:vtc:client:ui:cancel",{hide: true})
}

function switchToDriverMode(){
    driverMode = true
    elCourses.innerText = ""
    show(true, elCourses)
    show(false, elAskDriver)
}
function switchToClientMode(){
    driverMode = false
    show(false, elCourses)
    show(true, elAskDriver)
    resetAskForm()
}

function changeMode(){
    sendEvent("jbb:vtc:client:ui:changedMode", {driverMode: !driverMode}, function(data){
        if(data.success == true){
            if(driverMode==true){
                switchToClientMode();
            }
            else{
                switchToDriverMode();
            }
        }
        else{
            elInputSwitchMode.checked = driverMode
        }
    })
}

function displayMugshot(txdString, infos){
    var imgSrc = `https://nui-img/${txdString}/${txdString}?v=${Date.now()}`
    
    elClientMugshot.src=imgSrc
    elClientDetailsTxt.innerHTML = infos.join("<br/>")
    elClientInfos.classList.remove("hide")
}

function hideClientInfos(){
    elClientInfos.classList.add("hide")
}

document.addEventListener('click', function (event) {
	if (!event.target.matches('.jbb-vtc-accept')) return;
	event.preventDefault();
    var courseId = event.target.getAttribute('data-courseid');
    acceptCourse(courseId)
}, false);

window.addEventListener('message', (event) => {
    if (event.data.type === 'jbb:vtc:ui:showliste') {
        show(event.data.show, elDashboard)
    }
    else if (event.data.type === 'jbb:vtc:ui:showcurrent') {
        show(event.data.show, elCurrent)
    }
    else if (event.data.type === 'jbb:vtc:ui:addcourse') {
        addNewCourse(event.data.course);
    }
    else if (event.data.type === 'jbb:vtc:ui:delcourse') {
        deleteCourse(event.data.cid);
    }
    else if (event.data.type === 'jbb:vtc:ui:start') {
        startCourse(event.data.course);
    }
    else if (event.data.type === 'jbb:vtc:ui:updatesatisfaction') {
        updateSatisfaction(event.data.satisfaction);
    }
    else if (event.data.type === 'jbb:vtc:ui:updaterate') {
        updatePlayerRate(event.data.rate);
    }
    else if (event.data.type === 'jbb:vtc:ui:updatedistances') {
        updateDistances(event.data.courses);
    }
    else if (event.data.type === 'jbb:vtc:ui:pedmugshot') {
        displayMugshot(event.data.txdString, event.data.infos)
    }
    else if (event.data.type === 'jbb:vtc:ui:hideclientinfos') {
        elClientInfos.classList.add("hide")
    }
    //Client asking for a drive
    else if (event.data.type === 'jbb:vtc:ui:timeout') {
        resetAskForm();
    }
    else if (event.data.type === 'jbb:vtc:ui:driverfound') {
        driverFound(event.data.driver);
    }
    else if (event.data.type === 'jbb:vtc:ui:driverhere') {
        statusNear()
    }
    else if (event.data.type === 'jbb:vtc:ui:driverprogress') {
        statusInProgress()
    }
    else if (event.data.type === 'jbb:vtc:ui:driverarrived') {
        driverArrived()
    }
    else if (event.data.type === 'jbb:vtc:ui:clientreset') {
        resetAskForm()
    }
});

document.body.addEventListener('keydown', function (e) {
    switch(e.keyCode) {
        case 27: // ESCAPE
            sendEvent("jbb:vtc:client:ui:releasefocus",{})
            break;
    }
});
