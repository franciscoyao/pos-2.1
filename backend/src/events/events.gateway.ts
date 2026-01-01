import {
    OnGatewayConnection,
    OnGatewayDisconnect,
    OnGatewayInit,
    SubscribeMessage,
    WebSocketGateway,
    WebSocketServer,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
    cors: {
        origin: '*',
    },
})
export class EventsGateway
    implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect {
    @WebSocketServer() server: Server;
    private logger: Logger = new Logger('EventsGateway');

    afterInit(server: Server) {
        this.logger.log('WebSocket Gateway Initialized');
    }

    handleDisconnect(client: Socket) {
        this.logger.log(`Client disconnected: ${client.id}`);
    }

    handleConnection(client: Socket, ...args: any[]) {
        this.logger.log(`Client connected: ${client.id}`);
    }

    @SubscribeMessage('msgToServer')
    handleMessage(client: Socket, payload: any): void {
        this.server.emit('msgToClient', payload);
    }

    emitTableUpdate(table: any) {
        this.server.emit('table:update', table);
    }

    emitOrderUpdate(order: any) {
        this.server.emit('order:update', order);
    }

    emitNewOrder(order: any) {
        this.server.emit('order:new', order);
    }

    emitCategoryUpdate(category: any) {
        this.server.emit('category:update', category);
    }

    emitMenuItemUpdate(menuItem: any) {
        this.server.emit('menu-item:update', menuItem);
    }

    emitUserUpdate(user: any) {
        this.server.emit('user:update', user);
    }
}
