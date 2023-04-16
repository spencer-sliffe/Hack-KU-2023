

const firebaseConfig = {
    apiKey: "AIzaSyClFZ_ak9CDSiwyhxHBLNjMlyV-RFTAyFk",
    authDomain: "tarpit-2f6b5.firebaseapp.com",
    projectId: "tarpit-2f6b5",
    storageBucket: "tarpit-2f6b5.appspot.com",
    messagingSenderId: "452460868905",
    appId: "1:452460868905:web:f57e1801d203513a92f338",
    measurementId: "G-ZW6MYET04E"
  };
  
    firebase.initializeApp(firebaseConfig);
    var database = firebase.database();
//posts functions 
    function savePost(){
        var name=document.getElementById('name').value
        var user=document.getElementById('user').value
        var description=document.getElementById('desc').value
        var file=document.getElementById('file').value
        var posts=document.getElementById('posts').value
        var today=new Date();
        var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
        var dateTime = date+' '+time;
        database.ref('Posts/'+ username).set({
            Author: user,
            title: name,
            descripton: description,
            fileURL:file,
            
            timestamp: dateTime
        })
    }
    
    function get(){
    var user=document.getElementById('user')
    var postRef=database.ref('Posts/'+'')
    postRef.ref.on('value',function(snapshot){
       var data = snapshot.val()
        alert(data.user)
    })
    }

    function delPost(){
        var name=document.getElementById('name').value

        database.ref('Posts/'+name).remove()
        alert(name+" Deleted")
    }
    function updatePost(){
        var name=document.getElementById('name').value
        var description=document.getElementById('desc').value
        var file=document.getElementById('file').value
        var today=new Date();
        var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
        var dateTime = date+' '+time;

        var update={
            descripton: description,
            fileURL:file,
            timestamp: dateTime}
        database.ref('Posts/'+ name).update(update)
        alert(name+" Deleted")

    }
  
//User functions 

function saveUser(){
    var email=document.getElementById('email').value
    
    var password=document.getElementById('password').value
    var posts=document.getElementById('posts').value
    
    database.ref('Accounts/'+ username).set({
        email: email,
        Username: username,
        password: password,
        
    })
}

function getUser(){

var postRef=database.ref('Accounts/'+'')
postRef.ref.on('value',function(snapshot){
   var data = snapshot.val()
    alert(data.user)
})
}


function updateUser(){
    var name=document.getElementById('name').value
    var description=document.getElementById('desc').value
    var file=document.getElementById('file').value
    var today=new Date();
    var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
    var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
    var dateTime = date+' '+time;

    var update={
        password: password}
        
    database.ref('Accounts/'+ password).update(update)
    alert("Password Updated")
}

function getFireBaseData()
var data=database.ref('Posts/')
DataTransfer.on('value',function(snapshot){
    snaps.forEach(function(displaySnapshot) {
        var displayData= displaySnapshot
    });
})
function search()
