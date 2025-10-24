import { APP_URL, HOST_URL } from './env';

/**
 * Get the base URL for the application
 * Uses APP_URL if available, otherwise falls back to HOST_URL or current origin
 */
export const getBaseUrl = (): string => {
    if (APP_URL) {
        return APP_URL;
    }

    if (HOST_URL) {
        return HOST_URL;
    }

    // Fallback to current origin for local development
    if (typeof window !== 'undefined') {
        return window.location.origin;
    }

    // Default fallback
    return 'https://chartdb.io';
};

/**
 * Get the homepage URL for logo links
 * In local development, this should point to the local app
 * In production, this can point to the main ChartDB website
 */
export const getHomepageUrl = (): string => {
    const baseUrl = getBaseUrl();

    // If we're running locally (not on chartdb.io domain), use the local app
    if (
        baseUrl.includes('localhost') ||
        baseUrl.includes('127.0.0.1') ||
        baseUrl.includes('8081')
    ) {
        return baseUrl;
    }

    // For production deployments, you might want to point to the main website
    // or keep it local depending on your setup
    return baseUrl;
};
