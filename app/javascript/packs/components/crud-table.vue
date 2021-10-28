<template>
  <v-data-table :headers="headers" :items="items" :sort-by="config.defaultSortBy" class="elevation-2">
    <template v-slot:top>
      <v-toolbar flat color="white">
        <!-- <v-toolbar-title>{{ config.label }}</v-toolbar-title> -->
        <v-divider class="mx-4" inset vertical></v-divider>
        <v-spacer></v-spacer>
        <v-dialog v-model="dialog" max-width="500px">
          <template v-slot:activator="{ on }">
            <v-btn color="primary" dark class="mb-2" v-on="on">Neu</v-btn>
          </template>
          <v-card>
            <v-card-title>
              <span class="headline">{{ formTitle }}</span>
            </v-card-title>

            <v-card-text>
              <v-container>
                <v-row>
                  <v-col v-for="attribute in attributes" :key="attribute.value" cols="12" sm="6" md="4">
                      <!-- Needs logic to determine which kind of input is appropiate for attribute given -->
                      <v-text-field v-model="editedItem[attribute.value]" :label="attribute.text"></v-text-field>
                  </v-col>
                </v-row>
              </v-container>
            </v-card-text>

            <v-card-actions>
              <v-spacer></v-spacer>
              <v-btn color="blue darken-1" text @click="close">Abbrechen</v-btn>
              <v-btn color="blue darken-1" text @click="save(editedItem)">Speichern</v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
        <v-dialog v-model="dialogDelete" max-width="500px">            
          <v-card>
               <v-alert class="rounded-0"
                type="error"
                >
                    <v-row align="center">
                        <v-col class="grow">
                            Wirklich löschen?
                        </v-col>
                    </v-row>
                </v-alert>
            <v-card-actions>
              <v-spacer></v-spacer>
                <v-btn color="blue darken-1" text @click="closeDelete">Abbrechen</v-btn>
                <v-btn color="blue darken-1" text @click="deleteItemConfirm">Löschen</v-btn>
              <v-spacer></v-spacer>
            </v-card-actions>
          </v-card>
        </v-dialog>
      </v-toolbar>
    </template>
    <template v-slot:item.action="{ item }">
      <v-icon small class="mr-2" @click="editItem(item)">Bearbeiten</v-icon>
      <v-icon small @click="deleteItem(item)">Löschen</v-icon>
    </template>
    <template v-slot:no-data>
      <v-btn color="primary" @click="initialize">Aktualisieren</v-btn>
    </template>
  </v-data-table>
</template>

<script>
import axios from "axios";
export default {
  data: () => ({
    dialog: false,
    dialogDelete: false,
    validationErrors: false,
    headers: [],
    attributes: [],
    items: [],
    editedIndex: -1,
    editedItem: {},
    defaultItem: {}
  }),
  props: ['config'],
  computed: {
    formTitle() {
      return this.editedIndex === -1 ? "Neu" : "Bearbeiten";
    }
  },
  watch: {
    dialog(val) {
      val || this.close();
    },
    dialogDelete (val) {
        val || this.closeDelete()
      },
  },
  created() {
    this.initialize();
  },
  methods: {
    initialize() {      
        return axios
            .get(`/${this.config.crudPath}`)
            .then(response => {
                this.items = response.data.data;
                this.headers = response.data.headers;
                this.attributes = this.headers.filter((header)=> { return(header.value !== 'action') })
                this.attributes.forEach((attribute)=> {
                  this.editedItem[attribute.value] = ""
                  this.defaultItem[attribute.value] = ""
                })
            })
            .catch(e => {
                console.log(e);
            });
    },       
    editItem(item) {
        this.editedIndex = item.id;
        this.editedItem = Object.assign({}, item);
        this.dialog = true;
    },
    save(item) {
        if (this.editedIndex > -1) {
            console.log(this.editedItem)
            axios
            .put(`/${this.config.crudPath}/${item.id}`, this.editedItem)
            .then(response => {
              this.initialize();
              this.close();
            })
            .catch(error => {
              console.log(error);
            });
        } else {
            axios
                .post(`/${this.config.crudPath}`, {
                    user: this.editedItem
                })
                .then(response => {
                    let success = response.data.message === 'Success'
                    if(success) {
                      this.initialize();
                      this.close();
                    } else {
                      console.log('Something went wrong')
                    }
                })
                .catch(error => {
                    console.log(error);
                });
        }
    },
    deleteItem(item) {
        const index = this.items.indexOf(item);
        this.editedIndex = this.items.indexOf(item)
        this.editedItem = Object.assign({}, item)
        this.dialogDelete = true
        
    },
    deleteItemConfirm () {
        axios
            .delete(`/${this.config.crudPath}/${this.editedItem.id}`)
            .then(response => {
                //this.initialize();
                this.items.splice(this.editedIndex, 1)
                this.closeDelete()
            })
            .catch(error => {
                console.log(error)
            });
    },
    close() {
        this.dialog = false;
        setTimeout(() => {
            this.editedItem = Object.assign({}, this.defaultItem);
            this.editedIndex = -1;
        }, 300);
    },
    closeDelete () {
        this.dialogDelete = false
        this.$nextTick(() => {
          this.editedItem = Object.assign({}, this.defaultItem)
          this.editedIndex = -1
        })
      },
    setValidationErrors () {
      
    },
  },   
};
</script>