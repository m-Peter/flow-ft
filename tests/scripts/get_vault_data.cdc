// This script checks the FTVaultData view from ExampleToken
// is the expected one. This is merely used in testing,
// since we cannot return on-chain types to the test
// files yet.

import ExampleToken from "ExampleToken"
import FungibleToken from "FungibleToken"
import FungibleTokenMetadataViews from "FungibleTokenMetadataViews"
import MetadataViews from "MetadataViews"

pub fun main(address: Address): Bool {
    let account = getAccount(address)

    let vaultRef = account
        .getCapability(ExampleToken.VaultPublicPath)
        .borrow<&{MetadataViews.Resolver}>()
        ?? panic("Could not borrow a reference to the vault resolver")

    let vaultData = FungibleTokenMetadataViews.getFTVaultData(vaultRef)
        ?? panic("Token does not implement FTVaultData view")

    assert(ExampleToken.VaultStoragePath == vaultData.storagePath)
    assert(ExampleToken.ReceiverPublicPath == vaultData.receiverPath)
    assert(ExampleToken.VaultPublicPath == vaultData.metadataPath)
    assert(/private/exampleTokenVault == vaultData.providerPath)
    assert(Type<&ExampleToken.Vault{FungibleToken.Receiver}>() == vaultData.receiverLinkedType)
    assert(Type<&ExampleToken.Vault{FungibleToken.Provider}>() == vaultData.providerLinkedType)
    assert(Type<&ExampleToken.Vault{FungibleToken.Balance, MetadataViews.Resolver}>() == vaultData.metadataLinkedType)
    let vault <- vaultData.createEmptyVault()
    let vaultIsEmpty = vault.balance == 0.0
    assert(vaultIsEmpty)

    destroy vault

    return true
}
