extension Array {
    public func binarySearch(isLessThanTarget: (Element) -> Bool) -> Int {
        if isEmpty {
            return 0
        }
        
        var leftIndex: Int = 0
        var rightIndex: Int = count
        while true {
            if leftIndex == rightIndex {
                return leftIndex
            }
            let nextIndex: Int = (leftIndex + rightIndex) / 2
            let nextElement: Element = self[nextIndex]
            
            if isLessThanTarget(nextElement) {
                leftIndex = nextIndex + 1
            } else {
                rightIndex = nextIndex
            }
        }
    }
}
