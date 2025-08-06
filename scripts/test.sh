#!/bin/bash

# FinanZen Testing Script
# This script provides common testing tasks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Functions
run_unit_tests() {
    print_header "Running Unit Tests"
    flutter test test/unit/ --coverage
    print_success "Unit tests completed"
}

run_widget_tests() {
    print_header "Running Widget Tests"
    flutter test test/widget/
    print_success "Widget tests completed"
}

run_integration_tests() {
    print_header "Running Integration Tests"
    flutter test test/integration/
    print_success "Integration tests completed"
}

run_all_tests() {
    print_header "Running All Tests"
    flutter test --coverage
    print_success "All tests completed"
}

generate_coverage_report() {
    print_header "Generating Coverage Report"
    
    if [ ! -f "coverage/lcov.info" ]; then
        print_warning "No coverage data found. Running tests first..."
        flutter test --coverage
    fi
    
    if command -v genhtml &> /dev/null; then
        genhtml coverage/lcov.info -o coverage/html
        print_success "Coverage report generated at coverage/html/index.html"
    else
        print_warning "genhtml not found. Install lcov: brew install lcov"
    fi
}

clean_test_cache() {
    print_header "Cleaning Test Cache"
    flutter clean
    flutter pub get
    print_success "Test cache cleaned"
}

check_coverage() {
    print_header "Checking Coverage Thresholds"
    
    if [ ! -f "coverage/lcov.info" ]; then
        print_warning "No coverage data found. Running tests first..."
        flutter test --coverage
    fi
    
    # This is a simplified check - in a real project you might use lcov tools
    if [ -f "coverage/lcov.info" ]; then
        print_success "Coverage data available"
        print_warning "Manual coverage review recommended"
    else
        print_error "Coverage data not generated"
        exit 1
    fi
}

# Main script
case "$1" in
    "unit")
        run_unit_tests
        ;;
    "widget")
        run_widget_tests
        ;;
    "integration")
        run_integration_tests
        ;;
    "all")
        run_all_tests
        ;;
    "coverage")
        generate_coverage_report
        ;;
    "clean")
        clean_test_cache
        ;;
    "check")
        check_coverage
        ;;
    "help")
        echo "FinanZen Testing Script"
        echo ""
        echo "Usage: ./test.sh [COMMAND]"
        echo ""
        echo "Commands:"
        echo "  unit        Run unit tests only"
        echo "  widget      Run widget tests only"
        echo "  integration Run integration tests only"
        echo "  all         Run all tests"
        echo "  coverage    Generate coverage report"
        echo "  clean       Clean test cache"
        echo "  check       Check coverage thresholds"
        echo "  help        Show this help message"
        echo ""
        ;;
    *)
        print_warning "Unknown command. Use './test.sh help' for usage."
        run_all_tests
        ;;
esac
