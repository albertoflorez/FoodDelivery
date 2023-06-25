//const API_KEY = process.env.API_KEY;
//const PRIVATE_KEY = process.env.PRIVATE_KEY;
//const PEDIDO_CONTRACT_ADDRESS = process.env.PEDIDO_CONTRACT_ADDRESS;
//const ENTREGA_CONTRACT_ADDRESS = process.env.ENTREGA_CONTRACT_ADDRESS;
//const PAGO_CONTRACT_ADDRESS = process.env.PAGO_CONTRACT_ADDRESS;
//const COMPENSACION_CONTRACT_ADDRESS = process.env.COMPENSACION_CONTRACT_ADDRESS;
//const PRODUCTO_CONTRACT_ADDRESS = process.env.PRODUCTO_CONTRACT_ADDRESS;

//const CONSUMIDOR_WALLET_ADDRESS = process.env.CONSUMIDOR_WALLET_ADDRESS;
//const RESTAURANTE_WALLET_ADDRESS = process.env.RESTAURANTE_WALLET_ADDRESS;
//const REPARTIDOR_WALLET_ADDRESS = process.env.REPARTIDOR_WALLET_ADDRESS;

const CONSUMIDOR_WALLET_ADDRESS = "0xb3B03160c451462BcAFf14483f87E9B935bd62D1"
const RESTAURANTE_WALLET_ADDRESS = "0x2b13Fe1C61a37f1a0dB9f9faEA3861F620209954"
const REPARTIDOR_WALLET_ADDRESS = "0x1c263B5bD935A12d97FE48Cfd8A380D3C5963e0D"
const PRECIO = 0.001

const { ethers } = require("hardhat");
//const pedidoContract = require("../artifacts/contracts/contratoPedido.sol/Pedido.json");
//const entregaContract = require("../artifacts/contracts/contratoEntrega.sol/Entrega.json");
//const pagoContract = require("../artifacts/contracts/contratoPago.sol/Pago.json");
//const compensacionContract = require("../artifacts/contracts/contratoCompensacion.sol/Compensacion.json");
//const productoContract = require("../artifacts/contracts/contratoProducto.sol/Producto.json");

//const provider = new ethers.providers.EtherscanProvider(network = "sepolia", API_KEY);

//const signer = new ethers.Wallet(PRIVATE_KEY, provider);

//const pedido = new ethers.Contract(PEDIDO_CONTRACT_ADDRESS, pedidoContract.abi, signer);
//const entrega = new ethers.Contract(ENTREGA_CONTRACT_ADDRESS, entregaContract.abi, signer);
//const pago = new ethers.Contract(PAGO_CONTRACT_ADDRESS, pagoContract.abi, signer);
//const compensacion = new ethers.Contract(COMPENSACION_CONTRACT_ADDRESS, compensacionContract.abi, signer);
//const producto = new ethers.Contract(PRODUCTO_CONTRACT_ADDRESS, productoContract.abi, signer);

async function main() {

  const PedidoFact = await ethers.getContractFactory("Pedido");
  const EntregaFact = await ethers.getContractFactory("Entrega");
  const PagoFact = await ethers.getContractFactory("Pago");
  const CompensacionFact = await ethers.getContractFactory("Compensacion");
  const ProductoFact = await ethers.getContractFactory("Producto");

  console.log("Desplegando todos los contratos...");
  // Start deployment, returning a promise that resolves to a contract object
  const pedido = await PedidoFact.deploy();
  const entrega = await EntregaFact.deploy();
  const pago = await PagoFact.deploy();
  const compensacion = await CompensacionFact.deploy();
  const producto = await ProductoFact.deploy(pedido.address, entrega.address, pago.address, compensacion.address);
  console.log("Contrato pedido desplegado en la dirección:", pedido.address);
  console.log("Contrato entrega desplegado en la dirección:", entrega.address);
  console.log("Contrato pago desplegado en la dirección:", pago.address);
  console.log("Contrato compensacion desplegado en la dirección:", compensacion.address);
  console.log("Contrato producto desplegado en la dirección:", producto.address);
  const tx0 = await entrega.actors(CONSUMIDOR_WALLET_ADDRESS, RESTAURANTE_WALLET_ADDRESS, REPARTIDOR_WALLET_ADDRESS);
  await tx0.wait();
  console.log("Antes de realizar el pedido, este es el balance en los wallets...");
  const balanceConsumidor = await entrega.showuser();
  console.log("Wallet de Consumidor: ", ethers.utils.formatEther(balanceConsumidor));
  const balanceRestaurante = await entrega.showRest();
  console.log("Wallet de Restaurante: ", ethers.utils.formatEther(balanceRestaurante));
  const balanceRepartidor = await entrega.showDel();
  console.log("Wallet de Repartidor: ", ethers.utils.formatEther(balanceRepartidor));
  
  const a = (1000000000000000000 * PRECIO).toString();
  console.log("Petición de generación de Pedido de " +  PRECIO + " ETHER o el equivalente de " + a + " wei...");
  const tx1 = await producto.updateAndBuyProducto("Hamburguesa", a , RESTAURANTE_WALLET_ADDRESS, { value: ethers.utils.parseEther(PRECIO.toString())});
  await tx1.wait();

  console.log("Actualización de los wallet de los actores...");
  const tx21 = await entrega.actors(CONSUMIDOR_WALLET_ADDRESS, RESTAURANTE_WALLET_ADDRESS, REPARTIDOR_WALLET_ADDRESS);
  await tx21.wait();
  console.log("Actualización para indicar que el pedido se está preparando...");
  const tx22 = await pedido.updateEstado(1, entrega.address, pago.address);
  await tx22.wait();

  console.log("Actualización para indicar que el pedido se ha entregado...");
  const tx31 = await pedido.updateEstado(2, entrega.address, pago.address);
  await tx31.wait();
  console.log("Actualización para indicar que el pedido ha sido NORMAL...");
  const tx32 = await pedido.resolutionPedido(1, compensacion.address);
  await tx32.wait();

  console.log("Despues de realizar el pedido, siendo un pedido NORMAL, este es el balance en los wallets...");
  const balanceConsumidorAfter = await entrega.showuser();
  console.log("Wallet de Consumidor: ", ethers.utils.formatEther(balanceConsumidorAfter));
  const balanceRestauranteAfter = await entrega.showRest();
  console.log("Wallet de Restaurante: ", ethers.utils.formatEther(balanceRestauranteAfter));
  const balanceRepartidorAfter = await entrega.showDel();
  console.log("Wallet de Repartidor: ", ethers.utils.formatEther(balanceRepartidorAfter));
}

main()
.then(() => process.exit(0))
.catch(error => {
  console.error(error);
  process.exit(1);
});