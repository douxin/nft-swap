import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Factory", function () {
    async function deployMerchant() {
        const [owner, mchUser] = await ethers.getSigners();

        const Factory = await ethers.getContractFactory("Factory");
        const factory = await Factory.deploy();

        return {factory, owner, mchUser};
    }

    describe("Deployment", function () {
        it("Owner setup correct", async function () {
            const { owner, factory } = await loadFixture(deployMerchant);

            expect(await factory.owner()).to.equal(owner.address);
        });
    });
});
