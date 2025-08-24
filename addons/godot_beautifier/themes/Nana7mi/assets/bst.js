import { readFileSync, writeFileSync } from "fs"
import { createInterface } from "readline"

class TreeNode {
  constructor(value) {
    this.value = value
    this.left = null
    this.right = null
  }
}

class BinarySearchTree {
  constructor() {
    this.root = null
  }

  insert(value) {
    const newNode = new TreeNode(value)
    if (!this.root) {
      this.root = newNode
      return
    }
    this.insertNode(this.root, newNode)
  }

  insertNode(node, newNode) {
    if (newNode.value < node.value) {
      if (!node.left) {
        node.left = newNode
      } else {
        this.insertNode(node.left, newNode)
      }
    } else {
      if (!node.right) {
        node.right = newNode
      } else {
        this.insertNode(node.right, newNode)
      }
    }
  }

  inOrderTraversal(node, result) {
    if (node) {
      this.inOrderTraversal(node.left, result)
      result.push(node.value)
      this.inOrderTraversal(node.right, result)
    }
  }
}

async function replaceInFile(filePath, regex, replacement) {
  try {
    let data = readFileSync(filePath, "utf-8")
    const matches = data.match(regex)

    console.log("Matches found:", matches)

    if (!matches) {
      console.log("No matches found.")
      return
    }

    const bst = new BinarySearchTree()
    matches.forEach((match) => bst.insert(match))

    const results = []
    bst.inOrderTraversal(bst.root, results)

    const rl = createInterface({
      input: process.stdin,
      output: process.stdout,
    })

    let newData = data // Initialize newData with the original data

    const askUser = async (start, end) => {
      if (start > end) {
        console.log("All matches processed.")
        rl.close()
        return
      }

      const halfSize = Math.ceil((end - start + 1) / 2)
      const changedMatches = results.slice(start, start + halfSize)

      // Split data into lines for line number tracking
      const lines = data.split("\n")

      // Replace half of the matches in the newData
      changedMatches.forEach((match) => {
        let matchIndex = newData.indexOf(match)
        while (matchIndex !== -1) {
          // Calculate the line number
          const lineNumber = lines.slice(
            0,
            newData.slice(0, matchIndex).split("\n").length
          ).length

          console.log(
            `Replacing: ${match} with ${replacement} (Line: ${lineNumber})`
          )
          newData =
            newData.substring(0, matchIndex) +
            replacement +
            newData.substring(matchIndex + match.length)
          matchIndex = newData.indexOf(
            match,
            matchIndex + replacement.length
          ) // Find the next occurrence
        }
      })

      // Write the new data to the file
      writeFileSync(filePath, newData)
      console.log(
        "File updated with half of the matches replaced. Please check the file for changes."
      )

      const answer = await new Promise((resolve) => {
        rl.question(
          'Type "y" if the changes are correct, "n" if they are not: ',
          resolve
        )
      })

      if (answer.toLowerCase() === "y") {
        console.log("Changes accepted.")
      } else {
        console.log("Changes rejected. Reverting to previous state.")
        newData = data // Reset newData to the original data
      }

      // Continue searching in the next half
      askUser(start + halfSize, end)
    }

    askUser(0, results.length - 1)
  } catch (error) {
    console.error("An error occurred:", error)
  }
}

// Usage: node script.js <file-path> <regex> <replacement>
const [filePath, regexStr, replacement] = process.argv.slice(2)
const regex = new RegExp(regexStr, "gm")
console.log("Regex used:", regex)
console.log("Command line arguments:", process.argv)

replaceInFile(filePath, regex, replacement)
