<template lang="pug">
  v-data-table.elevation-2(:headers='headers', :items='items', :sort-by='config.defaultSortBy')
    template(v-slot:top)
      v-toolbar(flat, color='white')
        v-divider.mx-4(inset='', vertical='')
        v-spacer
        v-dialog(v-model='dialog', max-width='500px')
          template(v-slot:activator='{ on }')
            v-btn.mb-2(color='primary', dark='', v-on='on') Neu
          v-card
            v-card-title
              span.headline {{ formTitle }}
            v-card-text
              v-container
                v-row
                  v-col(v-for='attribute in attributes', :key='attribute.value', cols='12', sm='6', md='4')
                    // Needs logic to determine which kind of input is appropiate for attribute given
                    v-text-field(v-model='editedItem[attribute.value]', :label='attribute.text')
            v-card-actions
              v-spacer
              v-btn(color='blue darken-1', text, @click='close') Abbrechen
              v-btn(color='blue darken-1', text, @click='save(editedItem)') Speichern
        v-dialog(v-model='dialogDelete', max-width='500px')
          v-card
            v-alert.rounded-0(type='error')
              v-row(align='center')
                v-col.grow
                  | Wirklich l&ouml;schen?
            v-card-actions
              v-spacer
              v-btn(color='blue darken-1', text, @click='closeDelete') Abbrechen
              v-btn(color='blue darken-1', text, @click='deleteItemConfirm') L&ouml;schen
              v-spacer
    template(v-slot:item.action='{ item }')
      v-icon.mr-2(small, @click='editItem(item)') Bearbeiten
      v-icon(small, @click='deleteItem(item)') L&ouml;schen
    template(v-slot:no-data)
      v-btn(color='primary', @click='initialize') Aktualisieren
</template>

<script>
import axios from "axios";
  // Move axios to config, set default headers, etc. 
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