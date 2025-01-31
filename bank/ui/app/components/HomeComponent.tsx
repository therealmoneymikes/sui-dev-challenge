import { motion } from "framer-motion";
import React from "react";


/**
 * 
 * 
 * @copyright Made My Michael Roberts https://github.com/therealmoneymikes
 * 
 * 
 */
const HomeComponent = () => {
  return (
    <div className="flex flex-col min-h-screen items-center justify-center space-y-5">
      <h1 className="text-2xl text-center font-HoneyBear">
        Floks Animated NFT Collection
      </h1>

      <div className="flex flex-col justify-center items-center space-y-3">
        <p className="font-HoneyBear tracking-wide">
          <span className="font-bold text-orange-600">9999</span> of 10,000
          available
        </p>
        <p className="font-HoneyBear text-sm">0.1 ETH per Floks</p>
      </div>
      <motion.button
        initial={{
          boxShadow: "-6px 6px 0px 0px",
          color: "#C05621",
          backgroundColor: "white",
          scale: 1,
        }}
        whileHover={{
          boxShadow: "-6px 6px 0px 0px",
          color: "white",
          backgroundColor: "#C05621",
          scale: 1.1,
        }}
        transition={{
          boxShadow: { duration: 0.2, ease: "easeInOut" },
          color: { duration: 0.2, ease: "easeInOut" },
          backgroundColor: { duration: 0.2, ease: "easeInOut" },
          scale: { duration: 0.4, ease: "easeIn" },
        }}
        className="bg-orange-800 p-3"
        style={{
          border: "3px solid white",
          borderRadius: "10px",
          boxShadow: "-6px 6px 0px 0px",
        }}
      >
        <p className="font-HoneyBear" style={{ fontSize: "1.5em" }}>
          Mint Floks
        </p>
      </motion.button>
    </div>
  );
};

export default HomeComponent;
