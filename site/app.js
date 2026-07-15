const demoApps=[
  {id:"chrome",name:"Google Chrome",desc:"Navigateur rapide",logo:"googlechrome.svg",color:"#4285f4"},
  {id:"firefox",name:"Mozilla Firefox",desc:"Navigateur libre",logo:"firefox.svg",color:"#ff7139"},
  {id:"sevenzip",name:"7-Zip",desc:"Compression de fichiers",logo:"sevenzip.svg",color:"#596477"},
  {id:"vlc",name:"VLC media player",desc:"Lecteur multimédia",logo:"vlc.svg",color:"#f08a24"},
  {id:"discord",name:"Discord",desc:"Messages et appels",logo:"discord.svg",color:"#5865f2"},
  {id:"vscode",name:"Visual Studio Code",desc:"Éditeur de code",logo:"vscode.svg",color:"#168bd2"},
  {id:"spotify",name:"Spotify",desc:"Musique et podcasts",logo:"spotify.svg",color:"#1db954"},
  {id:"bitwarden",name:"Bitwarden",desc:"Mots de passe",logo:"bitwarden.svg",color:"#175ddc"},
  {id:"docker",name:"Docker Desktop",desc:"Conteneurs",logo:"docker.svg",color:"#2496ed"}
];
const selected=new Set();
const $=selector=>document.querySelector(selector);

function renderSoftware(){
  $("#softwareGrid").innerHTML=demoApps.map(app=>`<button class="software-card ${selected.has(app.id)?"selected":""}" data-demo-app="${app.id}" style="--app:${app.color}"><img src="assets/logos/${app.logo}" alt=""><span><strong>${app.name}</strong><small>${app.desc}</small></span><b>${selected.has(app.id)?"✓":"+"}</b></button>`).join("");
  $("#demoCount").textContent=selected.size;
  $("#dockCount").textContent=selected.size;
  $("#selectionDock").classList.toggle("hidden",selected.size===0);
}

function showPanel(name){
  document.querySelectorAll(".demo-nav").forEach(button=>button.classList.toggle("active",button.dataset.panel===name));
  document.querySelectorAll(".demo-panel").forEach(panel=>panel.classList.toggle("active",panel.id===`panel-${name}`));
}

let demoTimer;
function runSimulation(kind){
  const config={
    install:{icon:"↓",title:"Installation simulée",steps:["Préparation de la sélection","Téléchargement depuis les sources officielles","Installation silencieuse","Vérification finale"]},
    update:{icon:"↥",title:"Mise à jour simulée",steps:["Actualisation des sources WinGet","Mise à jour des applications","Recherche Windows Update","Vérification des pilotes"]},
    cleanup:{icon:"◇",title:"Nettoyage simulé",steps:["Analyse des zones sélectionnées","Suppression des fichiers temporaires","Nettoyage des caches","Calcul de l’espace récupéré"]}
  }[kind];
  clearInterval(demoTimer);
  $("#modalIcon").textContent=config.icon;$("#modalTitle").textContent=config.title;$("#modalDetail").textContent="Préparation...";$("#modalProgress").style.width="0%";$("#modalPercent").textContent="0%";$("#modalFinish").classList.add("hidden");$("#modalClose").disabled=true;$("#demoModal").classList.remove("hidden");
  let step=0;
  const advance=()=>{const percent=Math.min(100,(step+1)*25);$("#modalDetail").textContent=config.steps[step]||"Opération terminée";$("#modalProgress").style.width=`${percent}%`;$("#modalPercent").textContent=`${percent}%`;step++;if(step>=config.steps.length){clearInterval(demoTimer);setTimeout(()=>{$("#modalTitle").textContent="Simulation terminée";$("#modalDetail").textContent=kind==="cleanup"?"2,4 Go pourraient être récupérés sur cet exemple.":"Aucune modification n’a été effectuée sur votre ordinateur.";$("#modalFinish").classList.remove("hidden");$("#modalClose").disabled=false;if(kind==="install"){selected.clear();renderSoftware()}},450)}};
  setTimeout(advance,150);demoTimer=setInterval(advance,650);
}

document.addEventListener("click",event=>{
  const nav=event.target.closest("[data-panel]");if(nav)showPanel(nav.dataset.panel);
  const app=event.target.closest("[data-demo-app]");if(app){selected.has(app.dataset.demoApp)?selected.delete(app.dataset.demoApp):selected.add(app.dataset.demoApp);renderSoftware()}
});
$("#demoInstall").addEventListener("click",()=>runSimulation("install"));
$("#demoUpdate").addEventListener("click",()=>runSimulation("update"));
$("#demoCleanup").addEventListener("click",()=>runSimulation("cleanup"));
$("#modalFinish").addEventListener("click",()=>$("#demoModal").classList.add("hidden"));
$("#modalClose").addEventListener("click",()=>{if(!$("#modalClose").disabled)$("#demoModal").classList.add("hidden")});
renderSoftware();
