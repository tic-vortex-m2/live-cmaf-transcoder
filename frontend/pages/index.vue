<template>
  <v-container fluid>
    <v-row justify="center">
      <v-col lg="11">
        <overview-server
          v-for="server in servers"
          :key="server.uid"
          :server-uid="server.uid"
          class="mb-4"
        />
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup lang="ts">
const currentConfigUid = useCurrentConfigUid();
const api = useApi();
currentConfigUid.value = undefined;
const servers = useServers();
const title = useTitle();
title.value = "Live CMAF Transcoder";
</script>
