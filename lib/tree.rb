require_relative 'node'

class Tree
  attr_accessor :root

  def initialize(array)
    @last = array.uniq.length - 1
    @root = build_tree(array)
    @found = nil
  end

  def build_tree(array, first = 0, last = @last)
    arr = array.sort.uniq

    return nil if first > last

    mid = (first + last) / 2
    root = Node.new(arr[mid])
    root.left = build_tree(arr, first, mid - 1)
    root.right = build_tree(arr, mid + 1, last)
    root
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.root}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end

  def insert(root = @root, value)
    return Node.new(value) if root.nil?
    return root if root.root == value

    if value < root.root
      root.left = insert(root.left, value)
    elsif value > root.root
      root.right = insert(root.right, value)
    end
    root
  end

  def get_successor(curr)
    curr = curr.right
    curr = curr.left while !curr.nil? && !curr.left.nil?
    curr
  end

  def delete(root = @root, value)
    return root if root.nil?

    if root.root > value
      root.left = delete(root.left, value)
    elsif root.root < value
      root.right = delete(root.right, value)
    else
      return root.right if root.left.nil?
      return root.left if root.right.nil?

      succ = get_successor(root)
      root.root = succ.root
      root.right = delete(root.right, succ.root)
    end
    root
  end

  def find(value, root = @root)
    return if root.nil?

    @found = root if root.root == value
    find(value, root.left)
    find(value, root.right)
    @found
  end

  def level_order(root = @root, &my_block)
    return if root.nil?

    queue = []
    visited_values = []
    queue.push(root)
    until queue.empty?
      current = queue.shift
      if block_given?
        visited_values.push(current.root) if my_block.call
      else
        visited_values.push(current.root)
      end
      queue.push(current.left) unless current.left.nil?
      queue.push(current.right) unless current.right.nil?
    end
    visited_values
  end

  def inorder(root = @root, arr = [], &my_block)
    return if root.nil?

    inorder(root.left, arr)
    if block_given?
      arr << root.root if my_block.call
    else
      arr << root.root
    end
    inorder(root.right, arr)
    arr
  end

  def preorder(root = @root, arr = [], &my_block)
    return if root.nil?

    if block_given?
      arr << root.root if my_block.call
    else
      arr << root.root
    end
    preorder(root.left, arr)
    preorder(root.right, arr)
    arr
  end

  def postorder(root = @root, arr = [], &my_block)
    return if root.nil?

    postorder(root.left, arr)
    postorder(root.right, arr)
    if block_given?
      arr << root.root if my_block.call
    else
      arr << root.root
    end
    arr
  end

  def height(node, height = [], counter = 0)
    return 0 if node.nil?

    unless node.left.nil? && node.right.nil?
      counter += 1
      height << counter
    end
    height(node.right, height, counter)
    height(node.left, height, counter)
    height.max.nil? ? 0 : height.max
  end

  def depth(node, root = @root)
    return -1 if root.nil?

    dist = -1
    if root.root == node.root || (dist = depth(node, root.left)) >= 0 || (dist = depth(node, root.right)) >= 0
      dist += 1
    end
    dist
  end

  def balanced?(root = @root)
    return if root.nil?

    left_height = height(root.left)
    right_height = height(root.right)

    return false if (left_height - right_height).abs > 1

    balanced?(root.left)
    balanced?(root.right)
    true
  end

  def rebalance(root = @root)
    sorted_arr = inorder(root)
    @last = sorted_arr.uniq.length - 1
    @root = build_tree(sorted_arr)
  end
end
