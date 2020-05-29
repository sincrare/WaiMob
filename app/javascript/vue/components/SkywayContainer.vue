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
          <button id="js-join-trigger" class="btn btn-primary">
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
        <input v-model="localText">
        <button @click.prevent="handleSendMessage">
          Send
        </button>
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
  },
  created() {
  },
  async mounted() {
    const email = window.APP.rails.user.email;
    this.peer = new Peer(email, {key: process.env.SKYWAY_KEY, debug: 3});

    const roomId = `waimob_${this.roomId}`;
    const joinTrigger = document.getElementById('js-join-trigger');
    const remoteVideos = document.getElementById('js-remote-streams');

    this.localStream = await navigator.mediaDevices
      .getUserMedia({
        audio: true,
        video: true,
      })
      .catch(console.error);

    // Register join handler
    joinTrigger.addEventListener('click', () => {
      // Note that you need to ensure the peer has connected to signaling server
      // before using methods of peer instance.
      if (!this.peer.open) {
        return;
      }

      this.room = this.peer.joinRoom(roomId, {
        mode: 'sfu',
        stream: this.localStream,
      });

      this.room.once('open', this.handleJoin);

      this.room.on('peerJoin', peerId => {
        this.messages.push(`=== ${peerId} joined ===`);
      });

      // Render remote stream for new peer join in the room
      this.room.on('stream', async stream => {
        const newVideo = document.createElement('video');
        newVideo.srcObject = stream;
        newVideo.playsInline = true;
        // mark peerId to find it later at peerLeave event
        newVideo.setAttribute('data-peer-id', stream.peerId);
        remoteVideos.append(newVideo);
        await newVideo.play().catch(console.error);
      });

      this.room.on('data', ({ data, src }) => {
        // Show a message sent to the room and who sent
        this.messages.push(`${src}: ${data}`);
      });

      // for closing room members
      this.room.on('peerLeave', peerId => {
        const remoteVideo = remoteVideos.querySelector(
          `[data-peer-id=${peerId}]`
        );
        remoteVideo.srcObject.getTracks().forEach(track => track.stop());
        remoteVideo.srcObject = null;
        remoteVideo.remove();

        this.messages.push(`=== ${peerId} left ===`);
      });

      // for closing myself
      this.room.once('close', this.handleLeave);
    });

    this.peer.on('error', console.error);
  },
  methods: {
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
      this.messages.push('=== You joined ===');

      // Render local stream
      const localVideo = document.getElementById('js-local-stream');
      localVideo.muted = true;
      localVideo.srcObject = this.localStream;
      localVideo.playsInline = true;
      localVideo.play().catch(console.error);
    },
    handleLeave() {
      const localVideo = document.getElementById('js-local-stream');
      const remoteVideos = document.getElementById('js-remote-streams');

      this.messages.push('== You left ===');
      this.room = null;
      this.joined = false;
      localVideo.srcObject = null;
      localVideo.stop();

      Array.from(remoteVideos.children).forEach(remoteVideo => {
        remoteVideo.srcObject.getTracks().forEach(track => track.stop());
        remoteVideo.srcObject = null;
        remoteVideo.remove();
      });
    }
  }
};
</script>

<style lang="scss" scope>
video {
  width: 200px;
}
</style>
