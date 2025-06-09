import { LightningElement, wire, api } from "lwc";
import RetriveWrapper from "@salesforce/apex/NewOpportunityInline.RetriveWrapper";
import saveContact from "@salesforce/apex/NewOpportunityInline.saveContact";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import option1 from "./lwcdetails.html";

export default class Lwcdetails extends LightningElement {
  @api recordId;
  @api sectionName;
  @api allowOpen;
  nameEditMode = false;
  showSaveCancelBtn = false;
  index = 0;
  loading = false;
  loopcount = 0;
  isBoolean;
  isPickList;
  checkBoxValue;
  wrapList;
  optionvalue = [];
  updatedlist = {
    ID: this.recordId
  };

  get sectionClass() {
    return this.allowOpen ? "slds-section slds-is-open" : "slds-section";
  }

  connectedCallback() {
    if (typeof this.allowOpen === "undefined") this.allowOpen = true;
    this.fetchdata();
  }

  fetchdata() {
    console.log("--i am fetch data--");
    RetriveWrapper({ recordId: this.recordId })
      .then((result) => {
        this.wrapList = result;
        console.log(this.wrapList);
        this.loading = false;
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        this.wrapList = undefined;
      });
  }

  handleClick() {
    this.allowOpen = !this.allowOpen;
    this.index = 0;
  }

  inlineEditName() {
    this.nameEditMode = true;
    this.showSaveCancelBtn = true;
    this.index = 0;
  }

  get checkFieldApiName() {
    if (this.index < this.wrapList.length) {
      this.loopcount++;
      var singlelist = this.wrapList[this.index];
      if (singlelist.value != null) {
        let fieldvalue = Number(singlelist.value);
        if (fieldvalue >= 0) {
          singlelist.value = fieldvalue.toLocaleString();
        }
      }
      if (this.loopcount == 2) {
        this.index++;
        this.loopcount = 0;
      }

      if (singlelist.fieldAPI != "ID") {
        if (singlelist.dataType == "Boolean") {
          this.isBoolean = true;
          if (singlelist.value == "true") {
            this.checkBoxValue = true;
          } else {
            this.checkBoxValue = false;
          }
        } else {
          if (singlelist.dataType == "PickList") {
            this.isBoolean = false;
            this.isPickList = true;
            this.getpicklistOptionValue(singlelist);
          } else {
            this.isPickList = false;
            this.isBoolean = false;
          }
        }
        return true;
      }
      return false;
    }
  }

  handlecancel() {
    this.nameEditMode = false;
    this.showSaveCancelBtn = false;
    this.index = 0;
  }

  handleChange(event) {
    this.fieldName = event.target.name;
    this.fieldValue = event.target.value;
    this.updatedlist[this.fieldName] = this.fieldValue;
  }

  handleCheckBox(event) {
    this.fieldName = event.target.name;
    this.updatedlist[this.fieldName] = event.target.checked;
  }

  handleSave() {
    this.updatedlist["ID"] = this.recordId;
    var finallist = JSON.stringify(this.updatedlist);
    this.loading = true;

    saveContact({ acc: finallist })
      .then((result) => {
        if (result !== undefined) {
          const evt = new ShowToastEvent({
            title: "save",
            message: "successfully save done",
            variant: "success"
          });
          this.dispatchEvent(evt);
          this.nameEditMode = false;
          this.showSaveCancelBtn = false;
          this.index = 0;
          this.fetchdata();
          //setTimeout(this.fetchdata.bind(this), 3000);
        }
      })
      .catch((error) => {
        this.error = error;
        console.log("--error--" + error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error Updating record",
            message: "there is some error",
            variant: "error"
          })
        );
      });
  }

  getpicklistOptionValue(singlelist) {
    this.optionvalue = [];
    for (let val of singlelist.pickList) {
      var picklistvalue = {};
      picklistvalue.label = val;
      picklistvalue.value = val;
      this.optionvalue.push(picklistvalue);
    }
  }

  render() {
    console.log("i am render");
    this.index = 0;
    return option1;
  }
}
