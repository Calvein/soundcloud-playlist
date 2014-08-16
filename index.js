var $, ID, audio, controls, currentTrack, form, goTo, input, list, next, nextTrack, play, playPause, prev, prevTrack, showTracks, title;

ID = '5247b2c9dddfe7afb755c75a6198999d';

$ = function(sel, parent) {
  if (parent == null) {
    parent = document;
  }
  return parent.querySelector(sel);
};

form = $('form');

input = $('input');

list = $('ul');

controls = $('.controls');

prev = $('.prev');

play = $('.play');

title = $('.title');

next = $('.next');

audio = new Audio();

audio.controls = true;

form.appendChild(audio);

currentTrack = null;

showTracks = function(playlist) {
  var i, li, n, t, track, _i, _len, _ref;
  controls.removeAttribute('hidden');
  n = playlist.tracks.length;
  while (n) {
    i = Math.random() * n-- | 0;
    t = playlist.tracks[n];
    playlist.tracks[n] = playlist.tracks[i];
    playlist.tracks[i] = t;
  }
  _ref = playlist.tracks;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    track = _ref[_i];
    li = document.createElement('li');
    li.textContent = track.title;
    li.__data__ = track;
    list.appendChild(li);
  }
  currentTrack = list.firstChild;
  list.firstChild.classList.add('active');
  title.textContent = currentTrack.__data__.title;
  return audio.src = currentTrack.__data__.src;
};

playPause = function() {
  play.classList.toggle('pause');
  if (play.classList.contains('pause')) {
    play.textContent = '>';
    return audio.pause();
  } else {
    play.textContent = '||';
    return audio.play();
  }
};

play.addEventListener('click', playPause);

goTo = function(el, forcePlay) {
  var data, isPlaying;
  if (!el) {
    return;
  }
  currentTrack.classList.remove('active');
  currentTrack = el;
  currentTrack.classList.add('active');
  data = currentTrack.__data__;
  title.textContent = data.title;
  isPlaying = forcePlay || !audio.paused;
  audio.src = data.src;
  if (isPlaying) {
    return audio.play();
  }
};

list.addEventListener('click', function(e) {
  var el;
  el = e.target;
  if (el.nodeName !== 'LI') {
    return;
  }
  return goTo(el);
});

prevTrack = function() {
  return goTo(currentTrack.previousSibling);
};

prev.addEventListener('click', prevTrack);

nextTrack = function(e) {
  return goTo(currentTrack.nextSibling, e.type === 'ended');
};

next.addEventListener('click', nextTrack);

audio.addEventListener('ended', nextTrack);

document.addEventListener('keyup', function(e) {
  if ($(':focus')) {
    return;
  }
  switch (e.which) {
    case 32:
      return playPause();
    case 37:
      return prevTrack();
    case 39:
      return nextTrack();
  }
});

form.addEventListener('submit', function(e) {
  var uri, xhr;
  e.preventDefault();
  uri = 'http://api.soundcloud.com/resolve.json';
  uri += '?url=' + input.value;
  uri += '&client_id=' + ID;
  xhr = new XMLHttpRequest();
  xhr.open('GET', uri, true);
  xhr.onreadystatechange = function(e) {
    var error, playlist;
    if (this.readyState === 4) {
      if (this.status !== 200) {
        throw new Error('Error: ' + this.status);
      }
      try {
        playlist = JSON.parse(this.responseText);
      } catch (_error) {
        error = _error;
        throw error;
      }
      if (playlist.kind !== 'playlist') {
        throw new Error('Has to be a playlist');
      }
      playlist.tracks.forEach(function(song) {
        return song.src = song.stream_url + '?client_id=' + ID;
      });
      return showTracks(playlist);
    }
  };
  return xhr.send();
});
