// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./contratoPedido.sol";

contract Producto {
    
    address public seller;
    address payable public buyer;
    uint public price;
    address public contratoPedido;
    address public contratoEntrega;
    address public contratoPago;
    address public contratoCompensacion;

    event ListAdress(address buyer, address seller, address contratoPedido, address contratoEntrega, address contratoPago, address contratoCompensacion);
    event PurchasedItem(string producto, uint price);

    constructor(address cPedido, address cEntrega, address cPago, address cCompensacion) public payable {
        buyer = payable(msg.sender);
        contratoPedido = cPedido;
        contratoEntrega = cEntrega;
        contratoPago = cPago;
        contratoCompensacion = cCompensacion;
    }

    function updateAndBuyProducto(string memory producto, uint precio, address vendedor) public payable {
        require(msg.sender==buyer);
        seller = vendedor;
        price = precio;
        require(msg.value >= precio, "Tienes que poner Ether para poder comprarlo");
        emit ListAdress(buyer, seller, contratoPedido, contratoEntrega, contratoPago, contratoCompensacion);
        emit PurchasedItem(producto, price);
        buy();
    }

    function buy() private {
        Pedido miPedido = Pedido(contratoPedido);
        if (price > address(this).balance){
            miPedido.updateEstado(3,contratoEntrega, contratoPago);
            require(price <= address(this).balance, "No hay suficiente ether en este contrato.");
        } else {
            miPedido.deposit{value: price}();
            miPedido.updateEstado(0, contratoEntrega, contratoPago);
            uint amount = address(this).balance;
            (bool success, ) = buyer.call{value: amount}("");
            require(success, "Fallo enviando Ether");
        }
    }
}