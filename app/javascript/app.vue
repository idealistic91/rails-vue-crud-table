
<template>
  <div id="app">
    <v-app>
          <tableMenu :config="config"/>
          <crudTable :config="config"/>
    </v-app>
  </div>
</template>

<script>
import crudTable from "./packs/components/crud-table.vue";
import tableMenu from "./packs/components/table-menu.vue";
export default {
  data: function() {
    return {
      message: "Dynamic Crud Table",
      config: this.$parent.config
    };
  },
  components: {
    crudTable: crudTable,
    tableMenu: tableMenu
  }
};
</script>

<style scoped>
  p {
    font-size: 2em;
    text-align: center;
  }
</style>