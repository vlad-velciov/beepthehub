let tauntCollection   = [
  "Ownage.wav",
  "dominating.wav",
  "godlike.wav",
  "headshot.wav",
  "killingspree.wav",
  "megakill.wav",
  "monsterkill.wav",
  "rampage.wav",
  "multikill.wav",
  "ultrakill.wav",
  "triplekill.wav",
  "english.wav",
  "enough.wav",
  "shining_heres_johnny.wav",
  "t2_hasta_la_vista.wav",
  "t3_no_sh.wav",
  "t3_terminated.wav",
  "trippy_ew.wav"
];

let sounds = {
  playRandomTaunt: function() {
  let audio = new Audio('/images/' + tauntCollection[Math.floor(Math.random()*tauntCollection.length)]);
  audio.play();
}

}

export default sounds