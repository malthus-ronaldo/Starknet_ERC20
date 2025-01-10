#[starknet::interface]
trait IERC20<TContractState> {
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn totalSupply(self: @TContractState) -> felt252;
    fn balanceOf(self: @TContractState, account: starknet::ContractAddress) -> felt252;
    fn transfer(ref self: TContractState, recipient: starknet::ContractAddress, amount: felt252);
    fn transfer_from(
        ref self: TContractState,
        sender: starknet::ContractAddress,
        recipient: starknet::ContractAddress,
        amount: felt252,
    );
}

#[starknet::contract]
pub mod erc20 {
    use starknet::ContractAddress;
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePathEntry,
        StoragePointerWriteAccess
    };
    use starknet::get_caller_address;

    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        total_supply: felt252,
        balances: Map<ContractAddress, felt252>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Transfer: Transfer,
    }

    #[derive(Drop, starknet::Event)]
    pub struct Transfer {
        from: ContractAddress,
        to: ContractAddress,
        value: felt252,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        recipient: ContractAddress,
        name: felt252,
        symbol: felt252,
        total_supply: felt252,
    ) {
        self.name.write(name);
        self.symbol.write(symbol);
        self.total_supply.write(total_supply);
        self.mint(recipient, total_supply);
    }

    #[abi(embed_v0)]
    impl erc20 of super::IERC20<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        fn symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        fn totalSupply(self: @ContractState) -> felt252 {
            self.total_supply.read()
        }

        fn balanceOf(self: @ContractState, account: ContractAddress) -> felt252 {
            self.balances.read(account)
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: felt252) {
            let sender = get_caller_address();
            self._transfer(sender, recipient, amount);
        }

        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: felt252,
        ) {
            let caller = get_caller_address();
            self._transfer(sender, recipient, amount);
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _transfer(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: felt252,
        ) {
            assert!(self.balances.read(sender) - amount >= 0, "Insufficient balance");
            assert!(self.balances.read(sender) >= 0, "Insufficient balance");
            self.balances.write(sender, self.balances.read(sender) - amount);
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            self.emit(Transfer { from: sender, to: recipient, value: amount });
        }


        fn mint(ref self: ContractState, recipient: ContractAddress, amount: felt252) {
            let supply = self.total_supply.read() + amount;
            self.total_supply.write(supply);
            let recipient_balance = self.balances.read(recipient) + amount;
            self.balances.write(recipient, recipient_balance);
            self
                .emit(
                    Event::Transfer(
                        Transfer { from: ContractAddress::zero(), to: recipient, value: amount, },
                    ),
                );
        }
    }
}
