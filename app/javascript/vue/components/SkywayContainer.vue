<template>
  <div class="container p-3">
    <div class="room">
      <div class="mb-3">
        <template v-if="joined">
          <button id="js-leave-trigger" class="btn btn-warning" @click="handleClickLeave">
            Leave
          </button>
        </template>
        <template v-else>
          <button class="btn btn-primary" @click="handleClickJoin">
            Join
          </button>
        </template>
      </div>
      <div v-show="joined">
        <video id="js-local-stream" />
      </div>

      <div id="js-remote-streams" class="remote-streams" />

      <div>
        <ul class="list-unstyled">
          <template v-for="message in messages">
            <li v-text="message" />
          </template>
        </ul>
        <template v-if="joined">
          <div class="input-group mb-3">
            <input v-model="localText" type="text"
                   class="form-control"
                   placeholder="message">
            <div class="input-group-append">
              <button class="btn btn-outline-secondary" type="button" @click.prevent="handleSendMessage">
                Send
              </button>
            </div>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<script>
import Vue from 'vue';
import 'skyway-js';

export default {
  components: {
  },
  props: {
    roomId: {
      type: String,
      required: true,
    }
  },
  data() {
    return {
      messages: [],
      streams: [],
      localText: '',
      joined: false
    };
  },
  computed: {
    yourName() {
      return window.APP.rails.user.name;
    }
  },
  created() {
  },
  async mounted() {
    this.peer = new Peer(window.APP.rails.user.name, {key: window.APP.rails.skyway_key, debug: 1});
    this.peer.on('error', (e) => {
      console.error(e);
      this.room = null;
      this.localStream = null;
    });
  },
  methods: {
    async handleClickJoin() {
      if (!this.peer.open) {
        return;
      }

      const roomId = `waimob_${this.roomId}`;
      const remoteVideos = document.getElementById('js-remote-streams');

      this.localStream = await navigator.mediaDevices
        .getUserMedia({
          audio: true,
          video: true,
        })
        .catch(console.error);

      this.room = this.peer.joinRoom(roomId, {
        mode: 'sfu',
        stream: this.localStream,
      });

      this.room.once('open', this.handleJoin);
      this.room.once('close', this.handleLeave);
      this.room.on('stream', this.handleNewStream);
      this.room.on('peerLeave', this.handlePeerLeave);
      this.room.on('peerJoin', peerId => {
        this.messages.push(`${peerId} joined`);
      });
      this.room.on('data', ({ data, src }) => {
        this.messages.push(`${src}: ${data}`);
      });
    },
    handleClickLeave() {
      if (this.room) {
        this.room.close();
      }
    },
    handleSendMessage() {
      this.room.send(this.localText);
      this.messages.push(`${this.peer.id}: ${this.localText}`);
      this.localText = '';
    },
    handleJoin() {
      this.joined = true;
      this.messages.push(`${this.yourName} joined`);

      // Render local stream
      const localVideo = document.getElementById('js-local-stream');
      localVideo.muted = true;
      localVideo.srcObject = this.localStream;
      localVideo.playsInline = true;
      localVideo.play().catch(console.error);
    },
    handleLeave() {
      const localVideo = document.getElementById('js-local-stream');
      localVideo.srcObject = null;
      localVideo.pause();

      this.room = null;
      this.messages = [];
      this.joined = false;

      // this.localStream.getVideoTracks()[0].stop();
      // this.localStream = null;

      const remoteVideos = document.getElementById('js-remote-streams');
      Array.from(remoteVideos.children).forEach(remoteVideo => {
        remoteVideo.srcObject.getTracks().forEach(track => track.stop());
        remoteVideo.srcObject = null;
        remoteVideo.remove();
      });
    },
    async handleNewStream(stream) {
      const remoteVideos = document.getElementById('js-remote-streams');
      const newVideo = document.createElement('video');
      newVideo.srcObject = stream;
      newVideo.playsInline = true;
      // mark peerId to find it later at peerLeave event
      newVideo.setAttribute('data-peer-id', stream.peerId);
      remoteVideos.append(newVideo);
      await newVideo.play().catch(console.error);

    },
    handlePeerLeave(peerId) {
      const remoteVideos = document.getElementById('js-remote-streams');
      const remoteVideo = remoteVideos.querySelector(
        `[data-peer-id=${peerId}]`
      );
      remoteVideo.srcObject.getTracks().forEach(track => track.stop());
      remoteVideo.srcObject = null;
      remoteVideo.remove();

      this.messages.push(`${peerId} left`);
    }
  }
};
</script>

<style lang="scss" scope>
video {
  width: 200px;
}
</style>
