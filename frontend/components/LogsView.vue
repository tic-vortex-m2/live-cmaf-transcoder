<template>
  <v-card>
    <v-card-title>
      Logs
    </v-card-title>
    <v-card-text>
      <v-sheet
        class="d-flex align-start"
      >
        <v-checkbox
          v-model="info"
          color="info"
          label="info"
          hide-details
        />
        <v-checkbox
          v-model="warning"
          color="warning"
          label="warning"
          hide-details
        />
        <v-checkbox
          v-model="error"
          color="error"
          label="error"
          hide-details
        />
      </v-sheet>

      <v-infinite-scroll
        :height="300"
        :items="logs"
        mode="manual"
      >
        <template
          v-for="(item, index) in logs_filters"
          :key="item"
        >
          <div :class="['pa-2', index % 2 === 0 ? 'bg-grey-lighten-2' : '', color(item.level)]">
            {{ date(BigInt(item.timestamp)) }} [{{ item.level }}] {{ item.text }}
          </div>
        </template>

        <template #empty>
          <v-alert type="warning">
            No more logs!
          </v-alert>
        </template>

        <template #load-more>
          <div />
        </template>
      </v-infinite-scroll>
    </v-card-text>
  </v-card>
</template>
<script setup lang="ts">
import type { Log } from '~/backend/models/Log';
import type { LogLevel } from '~/backend/models/LogLevel';

const _props = defineProps<{
  configUid: string,
  serverUid: string
}>();
const api = useApi();
const logs: Ref<Array<Log>> = ref([]);
const info = ref(true);
const warning = ref(true);
const error = ref(true);
const refreshId = ref();

const logs_filters = computed(() => {
  return logs.value.filter((log) => {
    if (log.level === 'Info') {
      return info.value;
    }
    if (log.level === 'Warning') {
      return warning.value;
    }
    if (log.level === 'Error') {
      return error.value;
    }
    return false;
  });
});

function color(level: LogLevel) {
  switch (level) {
    case 'Error':
      return 'text-red';
    case 'Warning':
      return 'text-orange';
    default:
      return 'black-red';
  }
}

function date(timestamp: bigint) {
  return new Date(Number(timestamp) * 1000).toLocaleString();
}

async function startRefresh() {
  logs.value = await api.getLogs(_props.serverUid, _props.configUid);
}

onBeforeUnmount(() => {
  if (refreshId.value) {
    clearTimeout(refreshId.value);
  }
});

function getlogs() {

  refreshId.value = setTimeout(async () => {
    await startRefresh();
    getlogs();
  }, 3000);
}


onMounted(async () => {
  startRefresh();
  getlogs();
});

</script>