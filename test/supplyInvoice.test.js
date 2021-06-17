// test/supplyInvoice.test.js
// load dependencies
const { expect, assert } = require('chai');
 
// load compiled artifacts
const supplyInvoice = artifacts.require('supplyInvoice');
 
// start test block
contract('supplyInvoice', function (accounts) {
  before(function(){
    seller         = accounts[0];
    buyer          = accounts[1];
    carrier        = accounts[2];
    orderno        = 1;
    invoiceno      = 1;
    referenceNumber = 1;
    tokenId        = 1;
    link           = "example.json"

    // 0 - EXW, 1 - FCA, 2 - CPT, 3 - CIP, 4 - DAP, 5 - DPU, 6 - DDP, 7 - FAS, 8 - FOB, 9 - CFR, 10 - CIF
    tradeTerm = 1;
  });

  beforeEach(async function () {
    this.supplyInvoice = await supplyInvoice.new();
  });
 
  // test cases
  it('create new order', async function () {
    await this.supplyInvoice.createOrder(buyer, referenceNumber, link);
 
    // test if the returned value is the same one
    assert.equal((buyer,link), (buyer, referenceNumber, link), tokenId, "initial order minted");
  });

  it('cancel newly minted order', async function () {
    await this.supplyInvoice.createOrder(buyer, referenceNumber, link);
    await this.supplyInvoice.cancelOrder(tokenId);
  });

  it('create new invoice', async function () {
    await this.supplyInvoice.createOrder(buyer, referenceNumber, link);
    await this.supplyInvoice.createInvoice(buyer, seller, tokenId);
  });

  it('cancel invoice', async function () {
    await this.supplyInvoice.createOrder(buyer, referenceNumber, link);
    await this.supplyInvoice.createInvoice(buyer, seller, tokenId);
    await this.supplyInvoice.cancelInvoice(tokenId);
  });

  it('create new lading', async function () {
    await this.supplyInvoice.createOrder(buyer, referenceNumber, link);
    await this.supplyInvoice.createInvoice(buyer, seller, tokenId);
    await this.supplyInvoice.createLading(seller, carrier, tokenId);
  });

  it('assign tradeterms', async function () {
    await this.supplyInvoice.assignTradeTerms(tokenId, tradeTerm);
  });

  it('negotiate tradeterms', async function () {
    await this.supplyInvoice.createOrder(buyer, referenceNumber, link);
    await this.supplyInvoice.createInvoice(buyer, seller, tokenId);
    await this.supplyInvoice.negotiateTradeTerms(buyer, seller, tokenId);
  });

  it('determine liability', async function () {
    await this.supplyInvoice.createOrder(buyer, referenceNumber, link);
    await this.supplyInvoice.createInvoice(buyer, seller, tokenId);
    await this.supplyInvoice.determineLiability(buyer, seller, tokenId);
  });

  it('confirm shipment', async function () {
    await this.supplyInvoice.createOrder(buyer, referenceNumber, link);
    await this.supplyInvoice.createInvoice(buyer, seller, tokenId);
    await this.supplyInvoice.createLading(seller, carrier, tokenId);
    await this.supplyInvoice.confirmShipment(tokenId);
  });

  it('retrieve invoice', async function () {
    await this.supplyInvoice.createOrder(buyer, referenceNumber, link);
    await this.supplyInvoice.createInvoice(buyer, seller, tokenId);
    await this.supplyInvoice.createLading(seller, carrier, tokenId);
    await this.supplyInvoice.confirmShipment(tokenId);
    await this.supplyInvoice.retrieveInvoice(buyer, seller, carrier, tokenId);
  });
});    