"""
NCHMF Data Collector - Trung Tâm Dự Báo Khí Tượng Thủy Văn Quốc Gia

Reliability: 1.0 (100%) - Official Government Source
"""
import requests
from bs4 import BeautifulSoup
from datetime import datetime
from typing import List, Dict, Optional
import time
import re


class NCHMFCollector:
    """
    Collect weather and disaster warnings from NCHMF
    
    Website: http://nchmf.gov.vn/
    Update Frequency: Every 3-6 hours
    """
    
    BASE_URL = "http://nchmf.gov.vn"
    MAIN_PAGE = f"{BASE_URL}/KttvsWeb/vi-VN/1/index.html"
    
    def __init__(self, delay_seconds: float = 1.0):
        """
        Initialize collector
        
        Args:
            delay_seconds: Delay between requests to respect rate limits
        """
        self.delay_seconds = delay_seconds
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })
    
    def fetch_warnings(self, max_warnings: int = 50) -> List[Dict]:
        """
        Fetch latest weather warnings from NCHMF
        
        Args:
            max_warnings: Maximum number of warnings to fetch
            
        Returns:
            List of warning dicts with structure:
            {
                'id': str,
                'source': 'NCHMF',
                'source_reliability': 1.0,
                'content': str,
                'severity': str,  # 'low', 'medium', 'high', 'critical'
                'alert_type': str,  # 'weather', 'storm', 'flood', etc.
                'province': str,
                'district': Optional[str],
                'lat': Optional[float],
                'lng': Optional[float],
                'created_at': str,  # ISO 8601
                'verified': True,
                'confidence': 1.0
            }
        """
        warnings = []
        
        try:
            print(f"[NCHMF] Fetching warnings from {self.MAIN_PAGE}...")
            response = self.session.get(self.MAIN_PAGE, timeout=30)
            response.raise_for_status()
            
            # Parse HTML
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Find warning sections (adjust selectors based on actual HTML structure)
            warning_elements = self._find_warning_elements(soup)
            
            for element in warning_elements[:max_warnings]:
                try:
                    warning = self._parse_warning_element(element)
                    if warning:
                        warnings.append(warning)
                except Exception as e:
                    print(f"[NCHMF] Error parsing warning element: {e}")
                    continue
                
                # Rate limiting
                time.sleep(self.delay_seconds)
            
            print(f"[NCHMF] Fetched {len(warnings)} warnings")
            return warnings
            
        except requests.RequestException as e:
            print(f"[NCHMF] Error fetching data: {e}")
            return []
        except Exception as e:
            print(f"[NCHMF] Unexpected error: {e}")
            return []
    
    def _find_warning_elements(self, soup: BeautifulSoup) -> List:
        """
        Find warning elements in HTML
        
        Adjust selectors based on actual NCHMF website structure
        """
        warnings = []
        
        # Try multiple possible selectors
        selectors = [
            '.warning-item',
            '.alert-item',
            '.news-item',
            'div[class*="warning"]',
            'div[class*="alert"]',
            'article',
            '.content-item'
        ]
        
        for selector in selectors:
            elements = soup.select(selector)
            if elements:
                warnings.extend(elements)
                break
        
        # If no specific selectors found, look for text patterns
        if not warnings:
            # Look for divs containing warning keywords
            all_divs = soup.find_all('div', class_=True)
            for div in all_divs:
                text = div.get_text().lower()
                if any(keyword in text for keyword in ['cảnh báo', 'bão', 'lũ', 'mưa lớn', 'thiên tai']):
                    warnings.append(div)
        
        return warnings[:50]  # Limit to 50
    
    def _parse_warning_element(self, element) -> Optional[Dict]:
        """
        Parse a warning element into structured dict
        """
        text = element.get_text(strip=True)
        
        if not text or len(text) < 20:  # Skip very short texts
            return None
        
        # Extract severity from text
        severity = self._extract_severity(text)
        
        # Extract alert type
        alert_type = self._extract_alert_type(text)
        
        # Extract location (province)
        province = self._extract_province(text)
        
        # Extract date/time
        created_at = self._extract_datetime(element, text)
        
        # Generate unique ID
        alert_id = f"NCHMF_{int(created_at.timestamp())}"
        
        return {
            'id': alert_id,
            'source': 'NCHMF',
            'source_reliability': 1.0,
            'content': text,
            'severity': severity,
            'alert_type': alert_type,
            'province': province,
            'district': None,  # Usually not in NCHMF warnings
            'lat': None,  # Would need geocoding
            'lng': None,
            'created_at': created_at.isoformat(),
            'verified': True,
            'confidence': 1.0,
            'metadata': {
                'original_text': text[:200],  # First 200 chars
                'fetched_at': datetime.now().isoformat()
            }
        }
    
    def _extract_severity(self, text: str) -> str:
        """Extract severity level from text"""
        text_lower = text.lower()
        
        # Critical keywords
        if any(kw in text_lower for kw in ['nghiêm trọng', 'cực kỳ', 'rất nguy hiểm', 'cấp độ 4', 'cấp độ 5']):
            return 'critical'
        
        # High keywords
        if any(kw in text_lower for kw in ['cao', 'nguy hiểm', 'cấp độ 3', 'mạnh']):
            return 'high'
        
        # Medium keywords
        if any(kw in text_lower for kw in ['trung bình', 'cấp độ 2', 'vừa']):
            return 'medium'
        
        # Default to medium if unclear
        return 'medium'
    
    def _extract_alert_type(self, text: str) -> str:
        """Extract alert type from text"""
        text_lower = text.lower()
        
        if any(kw in text_lower for kw in ['bão', 'storm', 'typhoon']):
            return 'weather'
        elif any(kw in text_lower for kw in ['lũ', 'lụt', 'flood', 'ngập']):
            return 'disaster'
        elif any(kw in text_lower for kw in ['sơ tán', 'evacuation']):
            return 'evacuation'
        elif any(kw in text_lower for kw in ['mưa', 'rain', 'dông', 'thunder']):
            return 'weather'
        else:
            return 'general'
    
    def _extract_province(self, text: str) -> str:
        """Extract province name from text"""
        # Common Vietnamese provinces
        provinces = [
            'Hà Nội', 'Hồ Chí Minh', 'Đà Nẵng', 'Hải Phòng', 'Cần Thơ',
            'An Giang', 'Bà Rịa - Vũng Tàu', 'Bạc Liêu', 'Bắc Giang', 'Bắc Kạn',
            'Bắc Ninh', 'Bến Tre', 'Bình Định', 'Bình Dương', 'Bình Phước',
            'Bình Thuận', 'Cà Mau', 'Cao Bằng', 'Đắk Lắk', 'Đắk Nông',
            'Điện Biên', 'Đồng Nai', 'Đồng Tháp', 'Gia Lai', 'Hà Giang',
            'Hà Nam', 'Hà Tĩnh', 'Hải Dương', 'Hậu Giang', 'Hòa Bình',
            'Hưng Yên', 'Khánh Hòa', 'Kiên Giang', 'Kon Tum', 'Lai Châu',
            'Lâm Đồng', 'Lạng Sơn', 'Lào Cai', 'Long An', 'Nam Định',
            'Nghệ An', 'Ninh Bình', 'Ninh Thuận', 'Phú Thọ', 'Phú Yên',
            'Quảng Bình', 'Quảng Nam', 'Quảng Ngãi', 'Quảng Ninh', 'Quảng Trị',
            'Sóc Trăng', 'Sơn La', 'Tây Ninh', 'Thái Bình', 'Thái Nguyên',
            'Thanh Hóa', 'Thừa Thiên Huế', 'Tiền Giang', 'Trà Vinh', 'Tuyên Quang',
            'Vĩnh Long', 'Vĩnh Phúc', 'Yên Bái'
        ]
        
        text_lower = text.lower()
        for province in provinces:
            if province.lower() in text_lower:
                return province
        
        # Check for common abbreviations
        if 'tp.hcm' in text_lower or 'hcm' in text_lower:
            return 'Hồ Chí Minh'
        elif 'hà nội' in text_lower or 'hn' in text_lower:
            return 'Hà Nội'
        elif 'đà nẵng' in text_lower or 'dn' in text_lower:
            return 'Đà Nẵng'
        
        return 'Toàn quốc'  # Default if not found
    
    def _extract_datetime(self, element, text: str) -> datetime:
        """Extract datetime from element or text"""
        # Try to find date in element attributes
        date_str = element.get('data-date') or element.get('datetime')
        
        if date_str:
            try:
                return datetime.fromisoformat(date_str.replace('Z', '+00:00'))
            except:
                pass
        
        # Try to parse from text
        # Common patterns: "Ngày 15/01/2024", "15-01-2024", etc.
        date_patterns = [
            r'(\d{1,2})/(\d{1,2})/(\d{4})',
            r'(\d{1,2})-(\d{1,2})-(\d{4})',
            r'ngày\s+(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})',
        ]
        
        for pattern in date_patterns:
            match = re.search(pattern, text)
            if match:
                try:
                    day, month, year = map(int, match.groups())
                    return datetime(year, month, day)
                except:
                    continue
        
        # Default to current time
        return datetime.now()
    
    def fetch_historical_warnings(self, days_back: int = 30) -> List[Dict]:
        """
        Fetch historical warnings (if archive available)
        
        Args:
            days_back: Number of days to look back
            
        Returns:
            List of historical warnings
        """
        # This would require accessing NCHMF archive if available
        # For now, return empty list
        print(f"[NCHMF] Historical data fetching not yet implemented")
        return []


if __name__ == "__main__":
    # Test collector
    collector = NCHMFCollector()
    warnings = collector.fetch_warnings(max_warnings=10)
    
    print(f"\nFetched {len(warnings)} warnings:")
    for warning in warnings[:3]:
        print(f"\n- {warning['severity'].upper()}: {warning['content'][:100]}...")
        print(f"  Province: {warning['province']}")
        print(f"  Created: {warning['created_at']}")










