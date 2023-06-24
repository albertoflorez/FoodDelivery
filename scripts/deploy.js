async function main() {
    const PedidoFact = await ethers.getContractFactory("Pedido");
    const EntregaFact = await ethers.getContractFactory("Entrega");
    const PagoFact = await ethers.getContractFactory("Pago");
    const CompensacionFact = await ethers.getContractFactory("Compensacion");
    const ProductoFact = await ethers.getContractFactory("Producto");
 
    // Start deployment, returning a promise that resolves to a contract object
    const pedido = await PedidoFact.deploy();
    const entrega = await EntregaFact.deploy();
    const pago = await PagoFact.deploy();
    const compensacion = await CompensacionFact.deploy();
    const producto = await ProductoFact.deploy(pedido.address, entrega.address, pago.address, compensacion.address);
    console.log("Contract pedido deployed to address:", pedido.address);
    console.log("Contract entrega deployed to address:", entrega.address);
    console.log("Contract pago deployed to address:", pago.address);
    console.log("Contract compensacion deployed to address:", compensacion.address);
    console.log("Contract producto deployed to address:", producto.address);
 }
 
 main()
   .then(() => process.exit(0))
   .catch(error => {
     console.error(error);
     process.exit(1);
   });